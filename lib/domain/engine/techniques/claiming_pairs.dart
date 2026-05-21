import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class ClaimingPairs implements SudokuTechnique {
  @override
  Difficulty get level => .medium;

  @override
  List<Hint> getHints(SudokuGrid grid) {
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

        final firstBox = getBox(cellsWithDigit[0]);
        final sameBox = cellsWithDigit.every((i) => getBox(i) == firstBox);
        if (sameBox) {
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

        final firstBox = getBox(cellsWithDigit[0]);
        final sameBox = cellsWithDigit.every((i) => getBox(i) == firstBox);
        if (sameBox) {
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
