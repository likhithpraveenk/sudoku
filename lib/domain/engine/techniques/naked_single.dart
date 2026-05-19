import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [NakedSingle] definition.
class NakedSingle implements SudokuTechnique {
  @override
  int get level => 1;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var i = 0; i < 81; i++) {
      if (grid.valueAt(i) == 0) {
        final mask = grid.candidateMaskAt(i);
        // Count bits set in mask
        var count = 0;
        var digit = 0;
        for (var d = 1; d <= 9; d++) {
          if ((mask & (1 << (d - 1))) != 0) {
            count++;
            digit = d;
          }
        }
        if (count == 1) {
          return [DirectHint(i, digit, Difficulty.easy)];
        }
      }
    }
    return [];
  }
}
