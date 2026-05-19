import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [HiddenPair] definition.
class HiddenPair implements SudokuTechnique {
  @override
  int get level => 2;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      // We are looking for two digits that appear as candidates in exactly two
      // cells in this unit and those two cells have no other candidates besides
      // these two digits? Actually, hidden pair: The two digits are confined
      // to exactly two cells in the unit, but those cells may have other
      // candidates. We then remove all other candidates from those two cells.

      // For each pair of digits (d1, d2) with d1 < d2
      for (var d1 = 1; d1 <= 8; d1++) {
        for (var d2 = d1 + 1; d2 <= 9; d2++) {
          final cellsWithBoth = <int>[];
          for (final i in unit) {
            if (grid.valueAt(i) == 0) {
              final mask = grid.candidateMaskAt(i);
              final hasD1 = (mask & (1 << (d1 - 1))) != 0;
              final hasD2 = (mask & (1 << (d2 - 1))) != 0;
              if (hasD1 && hasD2) {
                cellsWithBoth.add(i);
              }
            }
          }
          // Check that these two digits appear only in these two cells in the
          // unit
          var onlyInTheseCells = true;
          for (final i in unit) {
            if (grid.valueAt(i) == 0) {
              final mask = grid.candidateMaskAt(i);
              final hasD1 = (mask & (1 << (d1 - 1))) != 0;
              final hasD2 = (mask & (1 << (d2 - 1))) != 0;
              if ((hasD1 || hasD2) && !cellsWithBoth.contains(i)) {
                onlyInTheseCells = false;
                break;
              }
            }
          }
          if (onlyInTheseCells && cellsWithBoth.length == 2) {
            // Found a hidden pair: cellsWithBoth[0] and cellsWithBoth[1] are
            // the two cells
            // Remove all other candidates from these two cells
            for (final cellIndex in cellsWithBoth) {
              final mask = grid.candidateMaskAt(cellIndex);
              final toRemove = <int>[];
              for (var d = 1; d <= 9; d++) {
                if (d != d1 && d != d2 && (mask & (1 << (d - 1))) != 0) {
                  toRemove.add(d);
                }
              }
              if (toRemove.isNotEmpty) {
                return [IndirectHint(cellIndex, toRemove, Difficulty.medium)];
              }
            }
          }
        }
      }
    }
    return [];
  }
}
