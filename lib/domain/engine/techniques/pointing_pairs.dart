import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [PointingPairs] definition.
class PointingPairs implements SudokuTechnique {
  @override
  int get level => 2;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    // Box indices: 18..26 in kGridUnits
    for (var boxIdx = 18; boxIdx < 27; boxIdx++) {
      final box = kGridUnits[boxIdx];
      for (var digit = 1; digit <= 9; digit++) {
        final cellsWithDigit = <int>[];
        for (final i in box) {
          if (grid.valueAt(i) == 0) {
            final mask = grid.candidateMaskAt(i);
            if ((mask & (1 << (digit - 1))) != 0) {
              cellsWithDigit.add(i);
            }
          }
        }
        if (cellsWithDigit.isEmpty) continue;

        // Check same row
        final firstRow = getRow(cellsWithDigit[0]);
        final sameRow = cellsWithDigit.every((i) => getRow(i) == firstRow);
        if (sameRow) {
          // Remove digit from all cells in that row NOT in this box
          for (var c = 0; c < 9; c++) {
            final idx = firstRow * 9 + c;
            final realBox = (firstRow ~/ 3) * 3 + (c ~/ 3);
            if (realBox != boxIdx - 18 && grid.valueAt(idx) == 0) {
              final mask = grid.candidateMaskAt(idx);
              if ((mask & (1 << (digit - 1))) != 0) {
                return [
                  IndirectHint(idx, [digit], Difficulty.medium),
                ];
              }
            }
          }
        }

        // Check same column
        final firstCol = getCol(cellsWithDigit[0]);
        final sameCol = cellsWithDigit.every((i) => getCol(i) == firstCol);
        if (sameCol) {
          for (var r = 0; r < 9; r++) {
            final idx = r * 9 + firstCol;
            final realBox = (r ~/ 3) * 3 + (firstCol ~/ 3);
            if (realBox != boxIdx - 18 && grid.valueAt(idx) == 0) {
              final mask = grid.candidateMaskAt(idx);
              if ((mask & (1 << (digit - 1))) != 0) {
                return [
                  IndirectHint(idx, [digit], Difficulty.medium),
                ];
              }
            }
          }
        }
      }
    }
    return [];
  }
}
