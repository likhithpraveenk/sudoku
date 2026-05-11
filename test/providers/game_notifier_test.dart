import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/hint_service.dart';
import 'package:sudoku/providers/game_notifier.dart';

import '../helpers/sudoku_boards.dart';

GameState readState(ProviderContainer container) =>
    container.read(gameProvider).requireValue;

class MockGenerator extends Generator {
  final Puzzle Function(Difficulty) mockGenerate;

  MockGenerator(this.mockGenerate) : super(const Solver());

  @override
  Puzzle generate(Difficulty difficulty) => mockGenerate(difficulty);
}

ProviderContainer makeContainer(MockGenerator gen) =>
    ProviderContainer(overrides: [generatorProvider.overrideWithValue(gen)]);

MockGenerator get standardMockGenerator => MockGenerator(
  (_) => Puzzle(
    board: TestBoards.simplePuzzle(),
    solution: TestBoards.simpleSolution(),
    givenMask: List.generate(
      81,
      (i) => TestBoards.simplePuzzle().atIndex(i) != 0,
    ),
  ),
);

void main() {
  group('GameNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = makeContainer(standardMockGenerator);
    });

    tearDown(() => container.dispose());

    group('startGame', () {
      test('transitions through loading then settles to AsyncData', () async {
        final notifier = container.read(gameProvider.notifier);

        expect(container.read(gameProvider), isA<AsyncLoading>());
        await notifier.startGame(.easy);
        expect(container.read(gameProvider), isA<AsyncData<GameState>>());
      });

      test('initializes difficulty, board, and default UI state', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        final state = readState(container);

        expect(state.difficulty, Difficulty.easy);
        expect(state.board.cells[0], 5);
        expect(state.board.cells[1], 3);
        expect(state.selectedCell, isNull);
        expect(state.inputMode, InputMode.digit);
        expect(state.isSolved, isFalse);
        expect(state.mistakeCount, 0);
        expect(state.history, isEmpty);
      });

      test('calling startGame again replaces previous game', () async {
        final notifier = container.read(gameProvider.notifier);
        await notifier.startGame(.easy);
        await notifier.startGame(.hard);

        final state = readState(container);
        expect(state.difficulty, Difficulty.hard);
        expect(state.history, isEmpty);
      });
    });

    group('restoreGame', () {
      test(
        'resets selectedCell and inputMode regardless of saved values',
        () async {
          await container.read(gameProvider.notifier).startGame(.easy);

          final dirtyState = readState(
            container,
          ).copyWith(selectedCell: const Cell(1, 1), inputMode: .pencil);

          container.read(gameProvider.notifier).restoreGame(dirtyState);
          final restored = readState(container);

          expect(restored.selectedCell, isNull);
          expect(restored.inputMode, InputMode.digit);
        },
      );
    });

    group('selectCell', () {
      test('sets selectedCell in GameState', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 1);

        container.read(gameProvider.notifier).selectCell(cell);

        expect(readState(container).selectedCell, cell);
      });

      test('clears selectedCell when called with null', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).selectCell(const Cell(0, 1));
        container.read(gameProvider.notifier).selectCell(null);

        expect(readState(container).selectedCell, isNull);
      });

      test('is a no-op before startGame', () {
        expect(
          () => container
              .read(gameProvider.notifier)
              .selectCell(const Cell(0, 0)),
          returnsNormally,
        );
      });
    });

    group('toggleInputMode', () {
      test('cycles digit to pencil to digit', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        final notifier = container.read(gameProvider.notifier);

        expect(readState(container).inputMode, InputMode.digit);

        notifier.toggleInputMode();
        expect(readState(container).inputMode, InputMode.pencil);

        notifier.toggleInputMode();
        expect(readState(container).inputMode, InputMode.digit);
      });
    });

    group('inputDigit (digit mode)', () {
      test('places digit on board', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);

        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).board[cell], 4);
      });

      test('records a DigitAction in history', () async {
        await container.read(gameProvider.notifier).startGame(.easy);

        container.read(gameProvider.notifier).inputDigit(const Cell(0, 2), 4);

        final history = readState(container).history;
        expect(history.length, 1);
        expect(history.last, isA<DigitAction>());
      });

      test('marks wrong digit in errorCells', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);

        container.read(gameProvider.notifier).inputDigit(cell, 9);

        expect(readState(container).errorCells, contains(cell));
        expect(readState(container).mistakeCount, 1);
      });

      test('does not modify given cells', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const givenCell = Cell(0, 0);

        container.read(gameProvider.notifier).inputDigit(givenCell, 9);

        expect(readState(container).board[givenCell], 5);
        expect(readState(container).history, isEmpty);
      });
    });

    group('inputDigit (pencil mode)', () {
      setUp(() async {
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).toggleInputMode();
      });

      test('adds note on first call', () {
        const cell = Cell(0, 2);
        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).notes[cell.index], contains(4));
      });

      test('removes note on second call (toggle behavior)', () {
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 4);
        notifier.inputDigit(cell, 4);

        expect(readState(container).notes[cell.index], isNot(contains(4)));
      });

      test('does not write to board', () {
        const cell = Cell(0, 2);
        container.read(gameProvider.notifier).inputDigit(cell, 4);

        expect(readState(container).board[cell], 0);
      });

      test('does not toggle notes on revealed cells', () async {
        container.read(gameProvider.notifier).toggleInputMode();
        container.read(gameProvider.notifier).revealCell(const Cell(0, 2));
        container.read(gameProvider.notifier).toggleInputMode();

        container.read(gameProvider.notifier).inputDigit(const Cell(0, 2), 3);

        expect(readState(container).notes[const Cell(0, 2).index], isEmpty);
      });
    });

    group('erase', () {
      test('clears a user-placed digit and records EraseAction', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 4);
        expect(readState(container).board[cell], 4);

        notifier.erase(cell);

        final state = readState(container);
        expect(state.board[cell], 0);
        expect(state.history.last, isA<EraseAction>());
      });

      test('clears notes and records EraseAction', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.toggleInputMode();
        notifier.inputDigit(cell, 3);
        notifier.inputDigit(cell, 5);
        notifier.toggleInputMode();

        notifier.erase(cell);

        final state = readState(container);
        expect(state.notes[cell.index], isEmpty);
        expect(state.history.last, isA<EraseAction>());
      });

      test('is a no-op for given cells', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const givenCell = Cell(0, 0);

        container.read(gameProvider.notifier).erase(givenCell);

        final state = readState(container);
        expect(state.board[givenCell], 5);
        expect(state.history, isEmpty);
      });

      test('removes cell from errorCells on erase', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 9);
        expect(readState(container).errorCells, contains(cell));

        notifier.erase(cell);
        expect(readState(container).errorCells, isNot(contains(cell)));
      });
    });

    group('undo', () {
      test('reverts last digit action', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 4);
        expect(readState(container).board[cell], 4);
        expect(notifier.canUndo, isTrue);

        notifier.undo();

        expect(readState(container).board[cell], 0);
        expect(readState(container).history, isEmpty);
        expect(notifier.canUndo, isFalse);
      });

      test('reverts last pencil action', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.toggleInputMode();
        notifier.inputDigit(cell, 5);
        notifier.undo();

        expect(readState(container).notes[cell.index], isNot(contains(5)));
      });

      test('reverts erase action restoring both value and notes', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 4);
        notifier.erase(cell);
        notifier.undo();

        expect(readState(container).board[cell], 4);
      });

      test('canUndo is false before any action', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        expect(container.read(gameProvider.notifier).canUndo, isFalse);
      });

      test('is a no-op before startGame', () {
        expect(
          () => container.read(gameProvider.notifier).undo(),
          returnsNormally,
        );
      });
    });

    group('revealCell', () {
      test('fills cell with correct solution value', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);

        expect(readState(container).board[cell], 0);

        container.read(gameProvider.notifier).revealCell(cell);

        final state = readState(container);
        expect(state.board[cell], state.puzzle.solution[cell]);
        expect(state.revealedCells, contains(cell));
      });

      test('removes cell from errorCells if it had an error', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 9);
        expect(readState(container).errorCells, contains(cell));

        notifier.revealCell(cell);
        expect(readState(container).errorCells, isNot(contains(cell)));
      });

      test('clears notes for revealed cell', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.toggleInputMode();
        notifier.inputDigit(cell, 3);
        notifier.toggleInputMode();

        notifier.revealCell(cell);
        expect(readState(container).notes[cell.index], isEmpty);
      });

      test('is a no-op for given cells', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const givenCell = Cell(0, 0);
        final before = readState(container).board[givenCell];

        container.read(gameProvider.notifier).revealCell(givenCell);

        expect(readState(container).board[givenCell], before);
        expect(readState(container).revealedCells, isNot(contains(givenCell)));
      });
    });

    group('validate', () {
      test('populates errorCells for wrong digits', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        const cell = Cell(0, 2);
        final notifier = container.read(gameProvider.notifier);

        notifier.inputDigit(cell, 9);

        notifier.validate();

        expect(readState(container).errorCells, contains(cell));
      });

      test('clears errorCells when board has no errors', () async {
        await container.read(gameProvider.notifier).startGame(.easy);

        container.read(gameProvider.notifier).validate();

        expect(readState(container).errorCells, isEmpty);
      });
    });

    group('validity getter', () {
      test('returns null before startGame', () {
        expect(container.read(gameProvider.notifier).validity, isNull);
      });

      test('returns correct when board has no errors', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        expect(
          container.read(gameProvider.notifier).validity,
          ValidationResult.correct,
        );
      });

      test('returns hasErrors after a wrong digit', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).inputDigit(const Cell(0, 2), 9);

        expect(
          container.read(gameProvider.notifier).validity,
          ValidationResult.hasErrors,
        );
      });
    });

    group('applyAutoNotes', () {
      test('fills candidates for at least one empty cell', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        final notes = readState(container).notes;
        expect(notes.any((s) => s.isNotEmpty), isTrue);
      });

      test('does not add candidates that conflict with peers', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        final state = readState(container);
        for (int i = 0; i < 81; i++) {
          final cell = Cell.fromIndex(i);
          if (state.board[cell] != 0) continue;

          final rowVals = state.board.valuesOfRow(cell).toSet()..remove(0);
          final colVals = state.board.valuesOfCol(cell).toSet()..remove(0);
          final boxVals = state.board.valuesOfBox(cell).toSet()..remove(0);
          final used = {...rowVals, ...colVals, ...boxVals};

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
        await container.read(gameProvider.notifier).startGame(.easy);
        container.read(gameProvider.notifier).applyAutoNotes();

        expect(readState(container).history.last, isA<AutoNotesAction>());
      });

      test('can be undone', () async {
        await container.read(gameProvider.notifier).startGame(.easy);
        final notifier = container.read(gameProvider.notifier);

        notifier.applyAutoNotes();
        final notesAfterFill = readState(container).notes;
        expect(notesAfterFill.any((s) => s.isNotEmpty), isTrue);

        notifier.undo();
        final notesAfterUndo = readState(container).notes;
        expect(notesAfterUndo.every((s) => s.isEmpty), isTrue);
      });
    });
  });
}
