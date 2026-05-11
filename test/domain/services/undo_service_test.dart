import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/undo_service.dart';

import '../../helpers/sudoku_boards.dart';

void main() {
  group('UndoService', () {
    late UndoService undoService;

    setUp(() {
      undoService = const UndoService();
    });

    test('canUndo returns false for empty history', () {
      final state = GameState.newGame(
        puzzle: Puzzle(
          board: TestBoards.empty(),
          solution: TestBoards.empty(),
          givenMask: List.generate(81, (_) => false),
        ),
        difficulty: .easy,
      );
      expect(undoService.canUndo(state), isFalse);
    });

    test('canUndo returns true for non-empty history', () {
      final state =
          GameState.newGame(
            puzzle: Puzzle(
              board: TestBoards.empty(),
              solution: TestBoards.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            history: [
              const DigitAction(
                cell: Cell(0, 0),
                previousValue: 0,
                newValue: 1,
              ),
            ],
          );
      expect(undoService.canUndo(state), isTrue);
    });

    test('pop does nothing when history is empty', () {
      final state = GameState.newGame(
        puzzle: Puzzle(
          board: TestBoards.empty(),
          solution: TestBoards.empty(),
          givenMask: List.generate(81, (_) => false),
        ),
        difficulty: .easy,
      );
      final result = undoService.pop(state);
      expect(result, equals(state));
    });

    test('pop undoes a DigitAction', () {
      const cell = Cell(0, 0);
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              board: TestBoards.empty(),
              solution: TestBoards.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            board: TestBoards.empty().setCell(cell, 1),
            history: [
              const DigitAction(cell: cell, previousValue: 0, newValue: 1),
            ],
          );

      final result = undoService.pop(initialState);
      expect(result.board[cell], 0);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes a PencilAction', () {
      const cell = Cell(0, 0);
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              board: TestBoards.empty(),
              solution: TestBoards.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            notes: List.generate(81, (_) => <int>{})..[cell.index] = {1},
            history: [
              const PencilAction(cell: cell, previousNotes: {}, newNotes: {1}),
            ],
          );

      final result = undoService.pop(initialState);

      expect(result.notes[cell.index].isEmpty, isTrue);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes an EraseAction', () {
      const cell = Cell(0, 0);
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              board: TestBoards.empty(),
              solution: TestBoards.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            board: TestBoards.empty().setCell(cell, 1),
            notes: List.generate(81, (_) => <int>{})..[cell.index] = {1},
            history: [
              const EraseAction(
                cell: cell,
                previousValue: 1,
                previousNotes: {1},
              ),
            ],
          );
      final result = undoService.pop(initialState);

      expect(result.board[cell], 1);
      expect(result.notes[cell.index].contains(1), isTrue);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes an AutoNotesAction', () {
      const cell = Cell(0, 0);
      final previousNotes = List.generate(81, (_) => <int>{})
        ..[cell.index] = {1, 2, 3};
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              board: TestBoards.empty(),
              solution: TestBoards.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            notes: List.generate(81, (_) => <int>{}),
            history: [AutoNotesAction(previousNotes: previousNotes)],
          );
      final result = undoService.pop(initialState);

      expect(result.notes[cell.index], equals({1, 2, 3}));
      expect(result.history.isEmpty, isTrue);
    });
  });
}
