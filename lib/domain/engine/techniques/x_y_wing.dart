import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [XYWing] definition.
class XYWing implements SudokuTechnique {
  @override
  int get level => 3;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    // Iterate all unsolved cells with exactly two candidates (potential pivot)
    for (var pivot = 0; pivot < 81; pivot++) {
      if (grid.valueAt(pivot) != 0) continue;
      final xy = grid.getCandidates(pivot);
      if (xy.length != 2) continue;
      final x = xy[0];
      final y = xy[1];

      // Find pincers among peers of pivot
      for (final pincer1 in kGridPeers[pivot]) {
        if (grid.valueAt(pincer1) != 0) continue;
        final cp1 = grid.getCandidates(pincer1);
        if (cp1.length != 2) continue;
        // Must contain x and a new digit z1 != y
        if (!cp1.contains(x)) continue;
        int? z1;
        for (final val in cp1) {
          if (val != x) {
            z1 = val;
            break;
          }
        }
        if (z1 == null || z1 == y) continue; // not a valid pincer

        // Second pincer: must contain y and the same z (z1)
        for (final pincer2 in kGridPeers[pivot]) {
          if (pincer2 == pincer1) continue;
          if (grid.valueAt(pincer2) != 0) continue;
          final cp2 = grid.getCandidates(pincer2);
          if (cp2.length != 2) continue;
          if (!cp2.contains(y)) continue;
          if (!cp2.contains(z1)) continue;

          // Both pincers found. Eliminate z1 from all cells that see both
          // pincer1 and pincer2.
          for (final target in kGridPeerSets[pincer1]) {
            if (kGridPeerSets[pincer2].contains(target) &&
                grid.valueAt(target) == 0 &&
                grid.isCandidate(target, z1)) {
              return [
                IndirectHint(target, [z1], Difficulty.hard),
              ];
            }
          }
        }
      }
    }
    return [];
  }
}
