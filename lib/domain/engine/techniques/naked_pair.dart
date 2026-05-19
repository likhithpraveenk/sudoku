import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [NakedPair] definition.
class NakedPair implements SudokuTechnique {
  @override
  int get level => 2;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      // get unsolved cells in this unit
      final unsolved = <int>[];
      for (final i in unit) {
        if (grid.valueAt(i) == 0) unsolved.add(i);
      }
      // try to find a naked pair (2 cells whose combined candidates are
      // exactly 2 digits)
      for (var a = 0; a < unsolved.length - 1; a++) {
        final ia = unsolved[a];
        final ca = grid.getCandidates(ia).toSet();
        if (ca.length > 2) continue; // cannot be part of a pair
        for (var b = a + 1; b < unsolved.length; b++) {
          final ib = unsolved[b];
          final cb = grid.getCandidates(ib).toSet();
          if (cb.length > 2) continue;
          final union = ca.union(cb);
          if (union.length == 2) {
            // Found a naked pair: ca and cb are subsets of union
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
