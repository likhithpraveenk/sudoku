import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/presentation/models/app_settings.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/game_session.dart';
import 'package:sudoku/providers/services_provider.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/stats_provider.dart';

import '../helpers/fake_services.dart';
import '../helpers/sudoku_grids.dart';

GameState readState(ProviderContainer container) =>
    container.read(gameProvider).requireValue!;

Future<void> pumpGame(ProviderContainer container) async {
  await container.read(gameProvider.future);
  // Keep a listener alive to prevent autoDispose from disposing the provider.
  container.listen(gameProvider, (_, _) {});
}

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this._settings);
  final AppSettings _settings;

  @override
  AppSettings build() => _settings;
}

class FakeStatsNotifier extends StatsNotifier {
  @override
  Map<Difficulty, List<StatRecord>> build() => {
    for (final d in Difficulty.values) d: <StatRecord>[],
  };

  @override
  void add(StatRecord record) {
    final current = state[record.difficulty] ?? const <StatRecord>[];
    state = {
      ...state,
      record.difficulty: [...current, record],
    };
  }

  @override
  Future<void> persistRecord(StatRecord record) async {
    // In-memory only for tests
    final current = state[record.difficulty] ?? const <StatRecord>[];
    if (!current.any((r) => r.completedAt == record.completedAt)) {
      state = {
        ...state,
        record.difficulty: [...current, record],
      };
    }
  }
}

class MockPuzzleGeneratorService implements PuzzleGeneratorService {
  int generateCalls = 0;

  @override
  String get name => 'mock';

  @override
  Future<Puzzle> generate(Difficulty difficulty) async {
    generateCalls++;
    return Puzzle(
      given: TestGrids.simplePuzzle(),
      solution: TestGrids.simpleSolution(),
    );
  }
}

ProviderContainer _makeContainer({
  AppSettings settings = const AppSettings(),
  FakeSaveGameService? saveGameService,
  Difficulty difficulty = Difficulty.easy,
}) {
  return ProviderContainer(
    overrides: [
      puzzleGeneratorServiceProvider.overrideWithValue(
        MockPuzzleGeneratorService(),
      ),
      settingsProvider.overrideWith(() => FakeSettingsNotifier(settings)),
      saveGameServiceProvider.overrideWithValue(
        saveGameService ?? FakeSaveGameService(),
      ),
      statsNotifierProvider.overrideWith(FakeStatsNotifier.new),
      difficultyProvider.overrideWith(() => FakeDifficultyNotifier(difficulty)),
    ],
  );
}

Future<void> solve(ProviderContainer container) async {
  final state = readState(container);
  final solution = state.puzzle.solution;
  final given = state.puzzle.given;
  final notifier = container.read(gameProvider.notifier);
  for (var i = 0; i < 81; i++) {
    if (given.valueAt(i) == 0) {
      await notifier.inputDigit(i, solution.valueAt(i), inputMode: .number);
    }
  }
}

void main() {
  group('GameNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    group('build', () {
      test('reads difficulty from difficultyProvider', () async {
        await pumpGame(container);

        expect(readState(container).difficulty, Difficulty.easy);
      });

      test('initial history is empty', () async {
        await pumpGame(container);

        expect(readState(container).history, isEmpty);
      });
    });

    test(
      'loads saved game when present in save service for difficulty',
      () async {
        final savedState = GameState.newGame(
          puzzle: Puzzle(
            given: TestGrids.simplePuzzle(),
            solution: TestGrids.simpleSolution(),
          ),
          difficulty: .easy,
        ).copyWith(elapsed: const Duration(minutes: 3));

        final service = FakeSaveGameService();
        await service.save(savedState);

        container = ProviderContainer(
          overrides: [
            puzzleGeneratorServiceProvider.overrideWithValue(
              MockPuzzleGeneratorService(),
            ),
            settingsProvider.overrideWith(
              () => FakeSettingsNotifier(const AppSettings()),
            ),
            saveGameServiceProvider.overrideWithValue(service),
          ],
        );

        await pumpGame(container);

        expect(readState(container).elapsed, const Duration(minutes: 3));
      },
    );

    test('generates new game when no saved game for difficulty', () async {
      await pumpGame(container);

      expect(readState(container).elapsed, Duration.zero);
    });

    test('starts the elapsed clock', () async {
      await pumpGame(container);

      await Future<void>.delayed(kTick);

      expect(readState(container).elapsed, greaterThan(Duration.zero));
    });

    group('persistence', () {
      test('a mutation saves the game', () async {
        final saves = FakeSaveGameService();
        container = _makeContainer(saveGameService: saves);
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);

        expect(saves.saveCalls, greaterThan(0));
      });

      test('solving the puzzle records a stat and clears the save', () async {
        final saves = FakeSaveGameService();
        container = _makeContainer(saveGameService: saves);
        await pumpGame(container);

        await solve(container);

        expect(readState(container).puzzleComplete, isTrue);
        expect(saves.deletedDifficulties, [Difficulty.easy]);
        expect(
          container.read(statsNotifierProvider)[Difficulty.easy],
          hasLength(1),
        );
      });
    });

    group('restart', () {
      test('resets grid to given puzzle', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);
        await container.read(gameProvider.notifier).restart();

        expect(readState(container).grid.valueAt(2), 0);
      });

      test('clears history', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);
        await container.read(gameProvider.notifier).restart();

        expect(readState(container).history, isEmpty);
      });

      test('preserves same puzzle', () async {
        await pumpGame(container);

        final puzzleBefore = readState(container).puzzle;

        await container.read(gameProvider.notifier).restart();

        expect(readState(container).puzzle, puzzleBefore);
      });
    });

    group('inputDigit routing', () {
      test('number mode writes grid value', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);

        expect(readState(container).grid.valueAt(2), 4);
      });

      test('pencil mode writes note not grid value', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .pencil);

        final state = readState(container);
        expect(state.notes[2], contains(4));
        expect(state.grid.valueAt(2), 0);
      });

      test('reads autoRemoveNotes from settingsProvider', () async {
        container.dispose();
        container = _makeContainer();
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();
        await container
            .read(gameProvider.notifier)
            .inputDigit(5, 4, inputMode: .pencil);
        container.read(boardProvider.notifier).toggleInputMode();
        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);

        expect(readState(container).notes[5], isNot(contains(4)));
      });
    });

    group('erase', () {
      test('erases the given cell index', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);
        await container.read(gameProvider.notifier).erase(2);

        expect(readState(container).grid.valueAt(2), 0);
      });

      test('erases the currently selected cell', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).selectCell(2);
        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);
        await container.read(gameProvider.notifier).erase(2);

        expect(readState(container).grid.valueAt(2), 0);
      });
    });

    group('runValidation', () {
      test('pushes error cells to boardProvider', () async {
        await pumpGame(container);

        final solution = readState(container).puzzle.solution;
        final correct = solution.valueAt(2);
        final wrong = correct == 9 ? 1 : correct + 1;

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, wrong, inputMode: .number);
        await container.read(gameProvider.notifier).runValidation();

        expect(container.read(boardProvider).errorCells, contains(2));
      });

      test('clears error cells for valid grid', () async {
        await pumpGame(container);

        await container.read(gameProvider.notifier).runValidation();

        expect(container.read(boardProvider).errorCells, isEmpty);
      });

      test('sets assists.validation on state', () async {
        await pumpGame(container);

        await container.read(gameProvider.notifier).runValidation();

        expect(readState(container).assists.validation, isTrue);
      });
    });

    group('canUndo', () {
      test('false before any action', () async {
        await pumpGame(container);

        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });

      test('true after action', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);

        expect(container.read(gameProvider.notifier).canUndo, isTrue);
      });

      test('false after undo clears last action', () async {
        await pumpGame(container);

        await container
            .read(gameProvider.notifier)
            .inputDigit(2, 4, inputMode: .number);
        await container.read(gameProvider.notifier).undo();

        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });
    });

    group('hint', () {
      test('sets assists.hints to true', () async {
        await pumpGame(container);

        await container.read(gameProvider.notifier).hint();

        expect(readState(container).assists.hints, isTrue);
      });
    });

    group('applyAutoNotes', () {
      test('sets assists.autoNotes to true', () async {
        await pumpGame(container);

        await container.read(gameProvider.notifier).applyAutoNotes();

        expect(readState(container).assists.autoNotes, isTrue);
      });
    });
  });
}
