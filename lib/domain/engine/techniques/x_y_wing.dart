import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class XYWing implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var pivot = 0; pivot < 81; pivot++) {
      if (grid.valueAt(pivot) != 0) continue;
      final xy = grid.getCandidates(pivot);
      if (xy.length != 2) continue;
      final x = xy[0];
      final y = xy[1];

      for (final pincer1 in kGridPeers[pivot]) {
        if (grid.valueAt(pincer1) != 0) continue;
        final cp1 = grid.getCandidates(pincer1);
        if (cp1.length != 2) continue;

        if (!cp1.contains(x)) continue;
        int? z1;
        for (final val in cp1) {
          if (val != x) {
            z1 = val;
            break;
          }
        }
        if (z1 == null || z1 == y) continue;

        for (final pincer2 in kGridPeers[pivot]) {
          if (pincer2 == pincer1) continue;
          if (grid.valueAt(pincer2) != 0) continue;
          final cp2 = grid.getCandidates(pincer2);
          if (cp2.length != 2) continue;
          if (!cp2.contains(y)) continue;
          if (!cp2.contains(z1)) continue;

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
