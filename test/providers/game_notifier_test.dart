import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';

import '../helpers/sudoku_grids.dart';

GameState readState(ProviderContainer container) =>
    container.read(gameProvider).requireValue!;

Future<void> pumpGame(ProviderContainer container) async {
  await container.read(gameProvider.future);
}

class MockPuzzleGeneratorService implements PuzzleGeneratorService {
  @override
  String get name => 'mock';

  @override
  Future<Puzzle> generate(Difficulty difficulty) async {
    return Puzzle(
      given: TestGrids.simplePuzzle(),
      solution: TestGrids.simpleSolution(),
    );
  }
}

void main() {
  group('GameNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          puzzleGeneratorServiceProvider.overrideWithValue(
            MockPuzzleGeneratorService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    group('build', () {
      test('loads initial game', () async {
        await pumpGame(container);

        final state = readState(container);

        expect(state.difficulty, Difficulty.easy);
        expect(state.grid.values[0], 5);
        expect(state.history, isEmpty);
      });

      test('starts as loading', () {
        expect(container.read(gameProvider), isA<AsyncLoading<GameState?>>());
      });

      test('settles to AsyncData', () async {
        await pumpGame(container);

        expect(container.read(gameProvider), isA<AsyncData<GameState?>>());
      });
    });

    group('restoreGame', () {
      test('restores exact state', () async {
        await pumpGame(container);

        final original = readState(container);

        final modified = original.copyWith(history: [...original.history]);

        container.read(gameProvider.notifier).restoreGame(modified);

        expect(readState(container), modified);
      });
    });

    group('inputDigit number mode', () {
      test('places digit on grid', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).grid.valueAt(2), 4);
      });

      test('records DigitAction', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).history.last, isA<DigitAction>());
      });

      test('ignores given cells', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).inputDigit(0, 9);

        final state = readState(container);

        expect(state.grid.valueAt(0), 5);
        expect(state.history, isEmpty);
      });
    });

    group('inputDigit pencil mode', () {
      setUp(() async {
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();
      });

      test('adds note', () {
        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).notes[2], contains(4));
      });

      test('toggles note off', () {
        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..inputDigit(2, 4);

        expect(readState(container).notes[2], isNot(contains(4)));
      });

      test('does not write grid value', () {
        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(readState(container).grid.valueAt(2), 0);
      });
    });

    group('erase', () {
      test('clears digit + records EraseAction', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).selectCell(2);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..erase();

        final state = readState(container);

        expect(state.grid.valueAt(2), 0);
        expect(state.notes[2], isEmpty);
        expect(state.history.last, isA<EraseAction>());
      });

      test('clears notes', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier)
          ..selectCell(2)
          ..toggleInputMode();

        container.read(gameProvider.notifier)
          ..inputDigit(2, 3)
          ..inputDigit(2, 5);

        container.read(boardProvider.notifier).toggleInputMode();

        container.read(gameProvider.notifier).erase();

        expect(readState(container).notes[2], isEmpty);
      });

      test('ignores given cells', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).selectCell(0);

        container.read(gameProvider.notifier).erase();

        final state = readState(container);

        expect(state.grid.valueAt(0), 5);
        expect(state.history, isEmpty);
      });
    });

    group('undo', () {
      test('reverts digit action', () async {
        await pumpGame(container);

        final notifier = container.read(gameProvider.notifier)
          ..inputDigit(2, 4);

        expect(readState(container).grid.valueAt(2), 4);

        notifier.undo();

        expect(readState(container).grid.valueAt(2), 0);
        expect(readState(container).history, isEmpty);
      });

      test('reverts note action', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).toggleInputMode();

        container.read(gameProvider.notifier)
          ..inputDigit(2, 5)
          ..undo();

        expect(readState(container).notes[2], isNot(contains(5)));
      });

      test('reverts erase action', () async {
        await pumpGame(container);

        container.read(boardProvider.notifier).selectCell(2);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 4)
          ..erase()
          ..undo();

        expect(readState(container).grid.valueAt(2), 4);
      });

      test('canUndo false initially', () async {
        await pumpGame(container);

        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });

      test('canUndo true after action', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).inputDigit(2, 4);

        expect(container.read(gameProvider.notifier).canUndo, isTrue);
      });
    });

    group('hint', () {
      test('reveals one cell', () async {
        await pumpGame(container);

        final before = readState(container);

        container.read(gameProvider.notifier).hint();

        final after = readState(container);

        expect(after.grid.values, isNot(equals(before.grid.values)));
      });
    });

    group('runValidation', () {
      test('populates error cells', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier)
          ..inputDigit(2, 9)
          ..runValidation();

        expect(container.read(boardProvider).errorCells, contains(2));
      });

      test('clears errors for valid grid', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).runValidation();

        expect(container.read(boardProvider).errorCells, isEmpty);
      });
    });

    group('applyAutoNotes', () {
      test('fills notes', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).applyAutoNotes();

        final notes = readState(container).notes;

        expect(notes.any((s) => s.isNotEmpty), isTrue);
      });

      test('records AutoNotesAction', () async {
        await pumpGame(container);

        container.read(gameProvider.notifier).applyAutoNotes();

        expect(readState(container).history.last, isA<AutoNotesAction>());
      });

      test('undo clears auto notes', () async {
        await pumpGame(container);

        final notifier = container.read(gameProvider.notifier)
          ..applyAutoNotes();

        notifier.undo();

        final notes = readState(container).notes;

        expect(notes.every((s) => s.isEmpty), isTrue);
      });
    });
  });
}
