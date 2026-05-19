import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [ClaimingPairs] definition.
class ClaimingPairs implements SudokuTechnique {
  @override
  int get level => 2;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    // Claiming Pairs: if a digit is confined to a single box within a row
    // or column, then it can be removed from the rest of the box.
    // We'll check each row and each column.

    // Check rows
    for (var row = 0; row < 9; row++) {
      final rowUnit = getRowUnit(row);
      for (var digit = 1; digit <= 9; digit++) {
        final cellsWithDigit = <int>[];
        for (final i in rowUnit) {
          if (grid.valueAt(i) == 0) {
            final mask = grid.candidateMaskAt(i);
            if ((mask & (1 << (digit - 1))) != 0) {
              cellsWithDigit.add(i);
            }
          }
        }
        if (cellsWithDigit.isEmpty) continue;

        // Check if all cellsWithDigit are in the same box
        final firstBox = getBox(cellsWithDigit[0]);
        final sameBox = cellsWithDigit.every((i) => getBox(i) == firstBox);
        if (sameBox) {
          // Remove digit from all cells in the box that are not in this row
          final boxUnit = getBoxUnit(firstBox);
          for (final i in boxUnit) {
            if (!rowUnit.contains(i) && grid.valueAt(i) == 0) {
              final mask = grid.candidateMaskAt(i);
              if ((mask & (1 << (digit - 1))) != 0) {
                return [
                  IndirectHint(i, [digit], Difficulty.medium),
                ];
              }
            }
          }
        }
      }
    }

    // Check columns
    for (var col = 0; col < 9; col++) {
      final colUnit = getColUnit(col);
      for (var digit = 1; digit <= 9; digit++) {
        final cellsWithDigit = <int>[];
        for (final i in colUnit) {
          if (grid.valueAt(i) == 0) {
            final mask = grid.candidateMaskAt(i);
            if ((mask & (1 << (digit - 1))) != 0) {
              cellsWithDigit.add(i);
            }
          }
        }
        if (cellsWithDigit.isEmpty) continue;

        // Check if all cellsWithDigit are in the same box
        final firstBox = getBox(cellsWithDigit[0]);
        final sameBox = cellsWithDigit.every((i) => getBox(i) == firstBox);
        if (sameBox) {
          // Remove digit from all cells in the box that are not in this column
          final boxUnit = getBoxUnit(firstBox);
          for (final i in boxUnit) {
            if (!colUnit.contains(i) && grid.valueAt(i) == 0) {
              final mask = grid.candidateMaskAt(i);
              if ((mask & (1 << (digit - 1))) != 0) {
                return [
                  IndirectHint(i, [digit], Difficulty.medium),
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
