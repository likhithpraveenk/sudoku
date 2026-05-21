import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class XWing implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var digit = 1; digit <= 9; digit++) {
      final rowsWithTwo = <int>[];
      for (var row = 0; row < 9; row++) {
        final cols = <int>[];
        for (var col = 0; col < 9; col++) {
          final index = row * 9 + col;
          if (grid.valueAt(index) == 0) {
            final mask = grid.candidateMaskAt(index);
            if ((mask & (1 << (digit - 1))) != 0) {
              cols.add(col);
            }
          }
        }
        if (cols.length == 2) {
          rowsWithTwo.add(row);
        }
      }

      for (var i = 0; i < rowsWithTwo.length; i++) {
        for (var j = i + 1; j < rowsWithTwo.length; j++) {
          final row1 = rowsWithTwo[i];
          final row2 = rowsWithTwo[j];

          final cols1 = _getColsForDigitInRow(grid, digit, row1);
          final cols2 = _getColsForDigitInRow(grid, digit, row2);
          if (cols1.length == 2 &&
              cols2.length == 2 &&
              cols1[0] == cols2[0] &&
              cols1[1] == cols2[1]) {
            final col1 = cols1[0];
            final col2 = cols1[1];
            for (var row = 0; row < 9; row++) {
              if (row != row1 && row != row2) {
                for (final col in [col1, col2]) {
                  final index = row * 9 + col;
                  if (grid.valueAt(index) == 0) {
                    final mask = grid.candidateMaskAt(index);
                    if ((mask & (1 << (digit - 1))) != 0) {
                      return [
                        IndirectHint(index, [digit], Difficulty.hard),
                      ];
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (var digit = 1; digit <= 9; digit++) {
      final colsWithTwo = <int>[];
      for (var col = 0; col < 9; col++) {
        final rows = <int>[];
        for (var row = 0; row < 9; row++) {
          final index = row * 9 + col;
          if (grid.valueAt(index) == 0) {
            final mask = grid.candidateMaskAt(index);
            if ((mask & (1 << (digit - 1))) != 0) {
              rows.add(row);
            }
          }
        }
        if (rows.length == 2) {
          colsWithTwo.add(col);
        }
      }
      for (var i = 0; i < colsWithTwo.length; i++) {
        for (var j = i + 1; j < colsWithTwo.length; j++) {
          final col1 = colsWithTwo[i];
          final col2 = colsWithTwo[j];
          final rows1 = _getRowsForDigitInCol(grid, digit, col1);
          final rows2 = _getRowsForDigitInCol(grid, digit, col2);
          if (rows1.length == 2 &&
              rows2.length == 2 &&
              rows1[0] == rows2[0] &&
              rows1[1] == rows2[1]) {
            final row1 = rows1[0];
            final row2 = rows1[1];
            for (var col = 0; col < 9; col++) {
              if (col != col1 && col != col2) {
                for (final row in [row1, row2]) {
                  final index = row * 9 + col;
                  if (grid.valueAt(index) == 0) {
                    final mask = grid.candidateMaskAt(index);
                    if ((mask & (1 << (digit - 1))) != 0) {
                      return [
                        IndirectHint(index, [digit], Difficulty.hard),
                      ];
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return [];
  }

  List<int> _getColsForDigitInRow(SudokuGrid grid, int digit, int row) {
    final cols = <int>[];
    for (var col = 0; col < 9; col++) {
      final index = row * 9 + col;
      if (grid.valueAt(index) == 0) {
        final mask = grid.candidateMaskAt(index);
        if ((mask & (1 << (digit - 1))) != 0) {
          cols.add(col);
        }
      }
    }
    return cols;
  }

  List<int> _getRowsForDigitInCol(SudokuGrid grid, int digit, int col) {
    final rows = <int>[];
    for (var row = 0; row < 9; row++) {
      final index = row * 9 + col;
      if (grid.valueAt(index) == 0) {
        final mask = grid.candidateMaskAt(index);
        if ((mask & (1 << (digit - 1))) != 0) {
          rows.add(row);
        }
      }
    }
    return rows;
  }
}
