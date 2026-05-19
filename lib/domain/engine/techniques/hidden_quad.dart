import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [HiddenQuad] definition.
class HiddenQuad implements SudokuTechnique {
  @override
  int get level => 4;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
      // Precompute for each digit the set of cells in the unit where it
      // is a candidate
      final digitToCells = <int, Set<int>>{};
      for (var digit = 1; digit <= 9; digit++) {
        final cells = <int>{};
        for (final i in unit) {
          if (grid.valueAt(i) == 0 && grid.isCandidate(i, digit)) {
            cells.add(i);
          }
        }
        digitToCells[digit] = cells;
      }

      // Iterate over all combinations of four distinct digits
      for (var d1 = 1; d1 <= 6; d1++) {
        for (var d2 = d1 + 1; d2 <= 7; d2++) {
          for (var d3 = d2 + 1; d3 <= 8; d3++) {
            for (var d4 = d3 + 1; d4 <= 9; d4++) {
              final s1 = digitToCells[d1]!;
              final s2 = digitToCells[d2]!;
              final s3 = digitToCells[d3]!;
              final s4 = digitToCells[d4]!;

              // Ensure none of the digit sets are empty
              if (s1.isEmpty || s2.isEmpty || s3.isEmpty || s4.isEmpty) {
                continue;
              }

              final union = <int>{}
                ..addAll(s1)
                ..addAll(s2)
                ..addAll(s3)
                ..addAll(s4);

              if (union.length == 4) {
                // Found a hidden quad: digits d1,d2,d3,d4 are confined to
                // exactly four cells (union).
                // Now, for each cell in the union, remove candidates that
                // are not d1,d2,d3,d4.
                final allowedDigits = <int>[d1, d2, d3, d4];
                for (final cellIndex in union) {
                  final toRemove = <int>[];
                  for (var digit = 1; digit <= 9; digit++) {
                    if (!allowedDigits.contains(digit) &&
                        grid.isCandidate(cellIndex, digit)) {
                      toRemove.add(digit);
                    }
                  }
                  if (toRemove.isNotEmpty) {
                    return [
                      IndirectHint(cellIndex, toRemove, Difficulty.expert),
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
