import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

class SudokuRules {
  const SudokuRules();

  Set<Cell> peers(Board board, Cell cell) => {
    ...board.rowCells(cell.row),
    ...board.colCells(cell.col),
    ...board.boxCells(cell.row ~/ 3, cell.col ~/ 3),
  }..remove(cell);

  bool isConflict(Board board, Cell cell, int value) {
    if (value == 0) return false;
    return peers(board, cell).any((p) => board[p] == value);
  }

  bool isSolved(Board board, Board solution) =>
      Board.allCells.every((c) => board[c] == solution[c]);

  GameState applyDigit(GameState state, Cell cell, int value) {
    if (state.puzzle.isGivenCell(cell)) return state;

    final action = DigitAction(
      cell: cell,
      previousValue: state.board[cell],
      newValue: value,
    );

    final newBoard = state.board.setCell(cell, value);

    final newNotes = state.notes.map(Set<int>.from).toList();
    if (value != 0) {
      for (final peer in peers(state.board, cell)) {
        newNotes[peer.index].remove(value);
      }
    }
    newNotes[cell.index].clear();

    final isWrong = value != 0 && value != state.puzzle.solution[cell];
    final newErrors = Set<Cell>.from(state.errorCells);
    isWrong ? newErrors.add(cell) : newErrors.remove(cell);

    final next = state.copyWith(
      board: newBoard,
      notes: newNotes,
      history: [...state.history, action],
      errorCells: newErrors,
      mistakeCount: isWrong ? state.mistakeCount + 1 : state.mistakeCount,
    );

    return isSolved(next.board, next.puzzle.solution)
        ? next.copyWith(isSolved: true)
        : next;
  }
}
