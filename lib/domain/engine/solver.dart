import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

class Solver {
  const Solver();

  Board? solve(Board board) {
    final cells = List<int>.from(board.cells);
    return _backtrack(cells) ? Board(cells) : null;
  }

  bool hasUniqueSolution(Board board) {
    final cells = List<int>.from(board.cells);
    return _countSolutions(cells) == 1;
  }

  bool _backtrack(List<int> cells) {
    final empty = _firstEmpty(cells);
    if (empty == -1) return true;

    final cell = Cell.fromIndex(empty);
    for (int digit = 1; digit <= 9; digit++) {
      if (isValid(cells, cell, digit)) {
        cells[empty] = digit;
        if (_backtrack(cells)) return true;
        cells[empty] = 0;
      }
    }
    return false;
  }

  int _countSolutions(List<int> cells) {
    final empty = _firstEmpty(cells);
    if (empty == -1) return 1;

    final cell = Cell.fromIndex(empty);
    int count = 0;
    for (int digit = 1; digit <= 9; digit++) {
      if (isValid(cells, cell, digit)) {
        cells[empty] = digit;
        count += _countSolutions(cells);
        cells[empty] = 0;
        if (count >= 2) return count;
      }
    }
    return count;
  }

  int _firstEmpty(List<int> cells) => cells.indexOf(0);

  bool isValid(List<int> cells, Cell cell, int digit) {
    final board = Board(cells);
    const rules = SudokuRules();
    return !rules.peers(board, cell).any((peer) => board[peer] == digit);
  }
}
