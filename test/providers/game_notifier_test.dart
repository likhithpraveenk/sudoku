import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/presentation/models/app_settings.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/services_provider.dart';
import 'package:sudoku/providers/settings_provider.dart';

import '../helpers/fake_services.dart';
import '../helpers/sudoku_grids.dart';

GameState readState(ProviderContainer container) =>
    container.read(gameProvider).requireValue!;

Future<void> pumpGame(ProviderContainer container) async {
  await container.read(gameProvider.future);
}

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this._settings);
  final AppSettings _settings;

  @override
  AppSettings build() => _settings;
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
  FakeStatsService? statsService,
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
      if (statsService != null)
        statsServiceProvider.overrideWithValue(statsService),
      difficultyProvider.overrideWith(() => FakeDifficultyNotifier(difficulty)),
    ],
  );
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

        final service = FakeSaveGameService()..save(savedState);

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

    group('restart', () {
      test('resets grid to given puzzle', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..restart();

        expect(readState(container).grid.valueAt(2), 0);
      });

      test('clears history', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..restart();

        expect(readState(container).history, isEmpty);
      });

      test('preserves same puzzle', () async {
        await pumpGame(container);

        final puzzleBefore = readState(container).puzzle;

        container.read(gameProvider.notifier).restart();

        expect(readState(container).puzzle, puzzleBefore);
      });
    });

    group('inputDigit routing', () {
      test('number mode writes grid value', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).grid.valueAt(2), 4);
      });

      test('pencil mode writes note not grid value', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();

        container.read(gameProvider.notifier).inputDigit(2, 4);

        final state = readState(container);
        expect(state.notes[2], contains(4));
        expect(state.grid.valueAt(2), 0);
      });

      test('reads autoRemoveNotes from settingsProvider', () async {
        container.dispose();
        container = _makeContainer(
          settings: const AppSettings(autoRemoveNotes: true),
        );
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();
        container.read(gameProvider.notifier).inputDigit(5, 4);
        container.read(boardProvider.notifier).toggleInputMode();
        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).notes[5], isNot(contains(4)));
      });
    });

    group('erase', () {
      test('erases selected cell when no index passed', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).selectCell(2);
        container.read(gameProvider.notifier).inputDigit(2, 4);

        container.read(gameProvider.notifier).erase();

        expect(readState(container).grid.valueAt(2), 0);
      });

      test('erases specific index when passed', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..erase(2);

        expect(readState(container).grid.valueAt(2), 0);
      });

      test('no-op when no cell selected and no index passed', () async {
        await pumpGame(container);

        // No selectCell call, no index — should not throw
        container.read(gameProvider.notifier).erase();

        expect(readState(container).history, isEmpty);
      });
    });

    group('runValidation', () {
      test('pushes error cells to boardProvider', () async {
        await pumpGame(container);

        final solution = readState(container).puzzle.solution;
        final correct = solution.valueAt(2);
        final wrong = correct == 9 ? 1 : correct + 1;

        container.read(gameProvider.notifier)
          ..inputDigit(2, wrong)
          ..runValidation();

        expect(container.read(boardProvider).errorCells, contains(2));
      });

      test('clears error cells for valid grid', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).runValidation();

        expect(container.read(boardProvider).errorCells, isEmpty);
      });

      test('sets assists.validation on state', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).runValidation();

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

        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(container.read(gameProvider.notifier).canUndo, isTrue);
      });

      test('false after undo clears last action', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..undo();

        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });
    });

    group('hint', () {
      test('sets assists.hints to true', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).hint();

        expect(readState(container).assists.hints, isTrue);
      });
    });

    group('applyAutoNotes', () {
      test('sets assists.autoNotes to true', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).applyAutoNotes();

        expect(readState(container).assists.autoNotes, isTrue);
      });
    });
  });
}
