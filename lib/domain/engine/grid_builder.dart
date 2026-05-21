import 'dart:math';

import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class GridBuilder {
  GridBuilder({Random? random}) : _random = random ?? Random();
  final Random _random;

  SudokuGrid build() {
    final cells = List<int>.filled(81, 0);
    _backtrack(cells);
    return SudokuGrid(values: cells);
  }

  bool _backtrack(List<int> cells) {
    final empty = cells.indexOf(0);
    if (empty == -1) return true;
    final digits = List.generate(9, (i) => i + 1)..shuffle(_random);
    for (final digit in digits) {
      if (isValid(cells, empty, digit)) {
        cells[empty] = digit;
        if (_backtrack(cells)) return true;
        cells[empty] = 0;
      }
    }
    return false;
  }
}
