import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class NakedTriple implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      final unsolved = <int>[];
      for (final i in unit) {
        if (grid.valueAt(i) == 0) unsolved.add(i);
      }

      for (var a = 0; a < unsolved.length - 2; a++) {
        final ia = unsolved[a];
        final ca = grid.getCandidates(ia).toSet();
        if (ca.length > 3) continue;
        for (var b = a + 1; b < unsolved.length - 1; b++) {
          final ib = unsolved[b];
          final cb = grid.getCandidates(ib).toSet();
          if (cb.length > 3) continue;
          for (var c = b + 1; c < unsolved.length; c++) {
            final ic = unsolved[c];
            final cc = grid.getCandidates(ic).toSet();
            if (cc.length > 3) continue;
            final union = ca.union(cb).union(cc);
            if (union.length == 3) {
              for (final i in unsolved) {
                if (i == ia || i == ib || i == ic) continue;
                final toRemove = union.intersection(
                  grid.getCandidates(i).toSet(),
                );
                if (toRemove.isNotEmpty) {
                  return [IndirectHint(i, toRemove.toList(), .hard)];
                }
              }
            }
          }
        }
      }
    }
    return [];
  }
}
