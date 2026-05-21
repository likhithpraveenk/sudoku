import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class NakedPair implements SudokuTechnique {
  @override
  Difficulty get level => .medium;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      final unsolved = <int>[];
      for (final i in unit) {
        if (grid.valueAt(i) == 0) unsolved.add(i);
      }

      for (var a = 0; a < unsolved.length - 1; a++) {
        final ia = unsolved[a];
        final ca = grid.getCandidates(ia).toSet();
        if (ca.length > 2) continue;
        for (var b = a + 1; b < unsolved.length; b++) {
          final ib = unsolved[b];
          final cb = grid.getCandidates(ib).toSet();
          if (cb.length > 2) continue;
          final union = ca.union(cb);
          if (union.length == 2) {
            for (final i in unsolved) {
              if (i == ia || i == ib) continue;
              final toRemove = grid
                  .getCandidates(i)
                  .toSet()
                  .intersection(union);
              if (toRemove.isNotEmpty) {
                return [IndirectHint(i, toRemove.toList(), Difficulty.medium)];
              }
            }
          }
        }
      }
    }
    return [];
  }
}
