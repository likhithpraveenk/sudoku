import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class XYZWing implements SudokuTechnique {
  @override
  Difficulty get level => .expert;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var pivot = 0; pivot < 81; pivot++) {
      if (grid.valueAt(pivot) != 0) continue;
      final xyz = grid.getCandidates(pivot);
      if (xyz.length != 3) continue;

      for (var zIdx = 0; zIdx < 3; zIdx++) {
        final z = xyz[zIdx];
        final x = xyz[(zIdx + 1) % 3];
        final y = xyz[(zIdx + 2) % 3];

        for (final pincer1 in kGridPeers[pivot]) {
          if (grid.valueAt(pincer1) != 0) continue;
          final cp1 = grid.getCandidates(pincer1);
          if (cp1.length != 2) continue;
          if (!cp1.contains(x) || !cp1.contains(z)) continue;

          for (final pincer2 in kGridPeers[pivot]) {
            if (pincer2 == pincer1) continue;
            if (grid.valueAt(pincer2) != 0) continue;
            final cp2 = grid.getCandidates(pincer2);
            if (cp2.length != 2) continue;
            if (!cp2.contains(y) || !cp2.contains(z)) continue;

            for (final target in kGridPeerSets[pivot]) {
              if (kGridPeerSets[pincer1].contains(target) &&
                  kGridPeerSets[pincer2].contains(target) &&
                  grid.valueAt(target) == 0 &&
                  grid.isCandidate(target, z)) {
                return [
                  IndirectHint(target, [z], Difficulty.expert),
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
