import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [NakedQuad] definition.
class NakedQuad implements SudokuTechnique {
  @override
  int get level => 3;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      final unsolved = <int>[];
      for (final i in unit) {
        if (grid.valueAt(i) == 0) unsolved.add(i);
      }
      if (unsolved.length < 5) continue;

      // Check every subset of 4 unsolved cells
      for (var a = 0; a < unsolved.length - 3; a++) {
        final ia = unsolved[a];
        final ca = grid.getCandidates(ia).toSet();
        if (ca.length > 4) continue;
        for (var b = a + 1; b < unsolved.length - 2; b++) {
          final ib = unsolved[b];
          final cb = grid.getCandidates(ib).toSet();
          if (cb.length > 4) continue;
          for (var c = b + 1; c < unsolved.length - 1; c++) {
            final ic = unsolved[c];
            final cc = grid.getCandidates(ic).toSet();
            if (cc.length > 4) continue;
            for (var d = c + 1; d < unsolved.length; d++) {
              final id = unsolved[d];
              final cd = grid.getCandidates(id).toSet();
              if (cd.length > 4) continue;

              final union = ca.union(cb).union(cc).union(cd);
              if (union.length == 4) {
                // Found a Naked Quad!
                // Eliminate union candidates from other unsolved cells in
                // this unit
                for (final i in unsolved) {
                  if (i == ia || i == ib || i == ic || i == id) continue;
                  final toRemove = union.intersection(
                    grid.getCandidates(i).toSet(),
                  );
                  if (toRemove.isNotEmpty) {
                    return [
                      IndirectHint(i, toRemove.toList(), Difficulty.expert),
                    ];
                  }
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
