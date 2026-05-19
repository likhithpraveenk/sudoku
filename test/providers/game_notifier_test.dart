import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/hint_service.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/providers/game_notifier.dart';

import '../helpers/sudoku_grids.dart';

GameState readState(ProviderContainer container) =>
    container.read(gameProvider).requireValue;

class MockPuzzleGeneratorService implements PuzzleGeneratorService {
  @override
  String get name => 'mock';

  @override
  Future<Puzzle> generate(Difficulty difficulty) async {
    return Puzzle(
      grid: TestGrids.simplePuzzle(),
      solution: TestGrids.simpleSolution(),
      givenMask: List.generate(
        81,
        (i) => TestGrids.simplePuzzle().valueAt(i) != 0,
      ),
    );
  }
}

void main() {
  group('GameNotifier', () {
    late ProviderContainer container;
    final mockService = MockPuzzleGeneratorService();

    setUp(() {
      container = ProviderContainer(
        overrides: [
          puzzleGeneratorServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    tearDown(() => container.dispose());

    group('startGame', () {
      test('transitions through loading then settles to AsyncData', () async {
        final notifier = container.read(gameProvider.notifier);

        expect(container.read(gameProvider), isA<AsyncLoading<GameState>>());
        await notifier.startGame(Difficulty.easy);
        expect(container.read(gameProvider), isA<AsyncData<GameState>>());
      });

      test('initializes difficulty, grid, and default UI state', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        final state = readState(container);

        expect(state.difficulty, Difficulty.easy);
        expect(state.grid.values[0], 5);
        expect(state.grid.values[1], 3);
        expect(state.selectedCell, isNull);
        expect(state.inputMode, InputMode.digit);
        expect(state.isSolved, isFalse);
        expect(state.mistakeCount, 0);
        expect(state.history, isEmpty);
      });

      test('calling startGame again replaces previous game', () async {
        final notifier = container.read(gameProvider.notifier);
        await notifier.startGame(Difficulty.easy);
        await notifier.startGame(Difficulty.hard);

        final state = readState(container);
        expect(state.difficulty, Difficulty.hard);
        expect(state.history, isEmpty);
      });
    });

    group('restoreGame', () {
      test(
        'resets selectedCell and inputMode regardless of saved values',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );

          final dirtyState = readState(
            container,
          ).copyWith(selectedCell: 10, inputMode: InputMode.pencil);

          container.read(gameProvider.notifier).restoreGame(dirtyState);
          final restored = readState(container);

          expect(restored.selectedCell, isNull);
          expect(restored.inputMode, InputMode.digit);
        },
      );
    });

    group('selectCell', () {
      test('sets selectedCell in GameState', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 1;

        container.read(gameProvider.notifier).selectCell(cell);

        expect(readState(container).selectedCell, cell);
      });

      test('clears selectedCell when called with null', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier)
          ..selectCell(1)
          ..selectCell(null);

        expect(readState(container).selectedCell, isNull);
      });

      test(
        'does not select cell when a global selectedDigit is active',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );
          container.read(gameProvider.notifier)
            ..selectDigit(4)
            ..selectCell(2);

          expect(readState(container).selectedDigit, 4);
          expect(readState(container).selectedCell, isNull);
          expect(readState(container).grid.valueAt(2), 4);
        },
      );
    });

    group('Digit First & Cell First Workflows', () {
      test(
        'Case 1.1: Pencil is on, Digit Selected - '
        'fills note, cell not selected',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );
          container.read(gameProvider.notifier)
            ..toggleInputMode()
            ..pressDigit(5)
            ..selectCell(2);

          expect(readState(container).inputMode, InputMode.pencil);
          expect(readState(container).selectedDigit, 5);
          expect(readState(container).notes[2], contains(5));
          expect(readState(container).selectedCell, isNull);
        },
      );

      test(
        'Case 1.2: Pencil is on, Cell Selected - '
        'adds note, cell remains selected',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );
          container.read(gameProvider.notifier)
            ..toggleInputMode()
            ..selectCell(2)
            ..pressDigit(5);

          expect(readState(container).inputMode, InputMode.pencil);
          expect(readState(container).selectedCell, 2);
          expect(readState(container).selectedDigit, isNull);
          expect(readState(container).notes[2], contains(5));
        },
      );

      test(
        'Case 2.1: Pencil is off, Digit Selected - '
        'fills value, cell not selected',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );
          container.read(gameProvider.notifier)
            ..pressDigit(5)
            ..selectCell(2);

          expect(readState(container).inputMode, InputMode.digit);
          expect(readState(container).selectedDigit, 5);
          expect(readState(container).selectedCell, isNull);
          expect(readState(container).grid.valueAt(2), 5);
        },
      );

      test(
        'Case 2.2: Pencil is off, Cell Selected - '
        'fills value, cell remains selected',
        () async {
          await container
              .read(gameProvider.notifier)
              .startGame(
                Difficulty.easy,
              );
          container.read(gameProvider.notifier)
            ..selectCell(2)
            ..pressDigit(5);

          expect(readState(container).inputMode, InputMode.digit);
          expect(readState(container).selectedCell, 2);
          expect(readState(container).selectedDigit, isNull);
          expect(readState(container).grid.valueAt(2), 5);
        },
      );
    });

    group('toggleInputMode', () {
      test('cycles digit to pencil to digit', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        final notifier = container.read(gameProvider.notifier);

        expect(readState(container).inputMode, InputMode.digit);

        notifier.toggleInputMode();
        expect(readState(container).inputMode, InputMode.pencil);

        notifier.toggleInputMode();
        expect(readState(container).inputMode, InputMode.digit);
      });
    });

    group('inputDigit (digit mode)', () {
      test('places digit on grid', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;

        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).grid.valueAt(cell), 4);
      });

      test('records a DigitAction in history', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);

        container.read(gameProvider.notifier).inputDigit(2, 4);

        final history = readState(container).history;
        expect(history.length, 1);
        expect(history.last, isA<DigitAction>());
      });

      test('marks wrong digit in errorCells', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;

        container.read(gameProvider.notifier).inputDigit(cell, 9);

        expect(readState(container).errorCells, contains(cell));
        expect(readState(container).mistakeCount, 1);
      });

      test('does not modify given cells', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const givenCell = 0;

        container.read(gameProvider.notifier).inputDigit(givenCell, 9);

        expect(readState(container).grid.valueAt(givenCell), 5);
        expect(readState(container).history, isEmpty);
      });
    });

    group('inputDigit (pencil mode)', () {
      setUp(() async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier).toggleInputMode();
      });

      test('adds note on first call', () {
        const cell = 2;
        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).notes[cell], contains(4));
      });

      test('removes note on second call (toggle behavior)', () {
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 4)
          ..inputDigit(cell, 4);

        expect(readState(container).notes[cell], isNot(contains(4)));
      });

      test('does not write to grid', () {
        const cell = 2;
        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).grid.valueAt(cell), 0);
      });

      test('does not toggle notes on revealed cells', () async {
        container.read(gameProvider.notifier)
          ..toggleInputMode()
          ..revealCell(2)
          ..toggleInputMode()
          ..inputDigit(2, 3);

        expect(readState(container).notes[2], isEmpty);
      });
    });

    group('erase', () {
      test('clears a user-placed digit and records EraseAction', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 4)
          ..erase(cell);

        final state = readState(container);
        expect(state.grid.valueAt(cell), 0);
        expect(state.history.last, isA<EraseAction>());
      });

      test('clears notes and records EraseAction', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..toggleInputMode()
          ..inputDigit(cell, 3)
          ..inputDigit(cell, 5)
          ..toggleInputMode()
          ..erase(cell);

        final state = readState(container);
        expect(state.notes[cell], isEmpty);
        expect(state.history.last, isA<EraseAction>());
      });

      test('is a no-op for given cells', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const givenCell = 0;

        container.read(gameProvider.notifier).erase(givenCell);

        final state = readState(container);
        expect(state.grid.valueAt(givenCell), 5);
        expect(state.history, isEmpty);
      });

      test('removes cell from errorCells on erase', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 9)
          ..erase(cell);

        expect(readState(container).errorCells, isNot(contains(cell)));
      });
    });

    group('undo', () {
      test('reverts last digit action', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        final notifier = container.read(gameProvider.notifier)
          ..inputDigit(
            cell,
            4,
          );
        expect(readState(container).grid.valueAt(cell), 4);
        expect(notifier.canUndo, isTrue);

        notifier.undo();

        expect(readState(container).grid.valueAt(cell), 0);
        expect(readState(container).history, isEmpty);
        expect(notifier.canUndo, isFalse);
      });

      test('reverts last pencil action', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..toggleInputMode()
          ..inputDigit(cell, 5)
          ..undo();

        expect(readState(container).notes[cell], isNot(contains(5)));
      });

      test('reverts erase action restoring both value and notes', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 4)
          ..erase(cell)
          ..undo();

        expect(readState(container).grid.valueAt(cell), 4);
      });

      test('canUndo is false before any action', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });
    });

    group('revealCell', () {
      test('fills cell with correct solution value', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;

        expect(readState(container).grid.valueAt(cell), 0);

        container.read(gameProvider.notifier).revealCell(cell);

        final state = readState(container);
        expect(state.grid.valueAt(cell), state.puzzle.solution.valueAt(cell));
        expect(state.revealedCells, contains(cell));
      });

      test('removes cell from errorCells if it had an error', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 9)
          ..revealCell(cell);

        expect(readState(container).errorCells, isNot(contains(cell)));
      });

      test('clears notes for revealed cell', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..toggleInputMode()
          ..inputDigit(cell, 3)
          ..toggleInputMode()
          ..revealCell(cell);

        expect(readState(container).notes[cell], isEmpty);
      });

      test('is a no-op for given cells', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const givenCell = 0;
        final before = readState(container).grid.valueAt(givenCell);

        container.read(gameProvider.notifier).revealCell(givenCell);

        expect(readState(container).grid.valueAt(givenCell), before);
        expect(readState(container).revealedCells, isNot(contains(givenCell)));
      });
    });

    group('validate', () {
      test('populates errorCells for wrong digits', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        const cell = 2;
        container.read(gameProvider.notifier)
          ..inputDigit(cell, 9)
          ..runValidation();

        expect(readState(container).errorCells, contains(cell));
      });

      test('clears errorCells when grid has no errors', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);

        container.read(gameProvider.notifier).runValidation();

        expect(readState(container).errorCells, isEmpty);
      });
    });

    group('validity getter', () {
      test('returns null before startGame', () {
        expect(container.read(gameProvider.notifier).validity, isNull);
      });

      test('returns correct when grid has no errors', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        expect(
          container.read(gameProvider.notifier).validity,
          ValidationResult.correct,
        );
      });

      test('returns hasErrors after a wrong digit', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier).inputDigit(2, 9);

        expect(
          container.read(gameProvider.notifier).validity,
          ValidationResult.hasErrors,
        );
      });
    });

    group('applyAutoNotes', () {
      test('fills candidates for at least one empty cell', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        final notes = readState(container).notes;
        expect(notes.any((s) => s.isNotEmpty), isTrue);
      });

      test('does not add candidates that conflict with peers', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        final state = readState(container);
        for (var i = 0; i < 81; i++) {
          final cell = i;
          if (state.grid.valueAt(cell) != 0) continue;

          final used = <int>{};
          for (final p in peersOf(cell)) {
            final v = state.grid.valueAt(p);
            if (v != 0) used.add(v);
          }

          for (final note in state.notes[i]) {
            expect(
              used,
              isNot(contains(note)),
              reason: 'Cell $cell has note $note which conflicts with peers',
            );
          }
        }
      });

      test('records AutoNotesAction in history', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        expect(readState(container).history.last, isA<AutoNotesAction>());
      });

      test('can be undone', () async {
        await container.read(gameProvider.notifier).startGame(Difficulty.easy);
        final notifier = container.read(gameProvider.notifier)
          ..applyAutoNotes();

        final notesAfterFill = readState(container).notes;
        expect(notesAfterFill.any((s) => s.isNotEmpty), isTrue);

        notifier.undo();
        final notesAfterUndo = readState(container).notes;
        expect(notesAfterUndo.every((s) => s.isEmpty), isTrue);
      });
    });
  });
}
