import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class HiddenSingle implements SudokuTechnique {
  @override
  Difficulty get level => .easy;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      for (var digit = 1; digit <= 9; digit++) {
        final positions = <int>[];
        for (final i in unit) {
          if (grid.valueAt(i) == 0) {
            final mask = grid.candidateMaskAt(i);
            if ((mask & (1 << (digit - 1))) != 0) {
              positions.add(i);
            }
          }
        }
        if (positions.length == 1) {
          final target = positions[0];
          return [DirectHint(target, digit, Difficulty.easy)];
        }
      }
    }
    return [];
  }
}
