import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class HiddenTriple implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (final unit in kGridUnits) {
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

      for (var d1 = 1; d1 <= 7; d1++) {
        for (var d2 = d1 + 1; d2 <= 8; d2++) {
          for (var d3 = d2 + 1; d3 <= 9; d3++) {
            final s1 = digitToCells[d1]!;
            final s2 = digitToCells[d2]!;
            final s3 = digitToCells[d3]!;
            if (s1.isEmpty || s2.isEmpty || s3.isEmpty) {
              continue;
            }
            final union = <int>{}
              ..addAll(s1)
              ..addAll(s2)
              ..addAll(s3);
            if (union.length == 3) {
              final toRemoveDigits = <int>[];
              for (var digit = 1; digit <= 9; digit++) {
                if (digit != d1 && digit != d2 && digit != d3) {
                  toRemoveDigits.add(digit);
                }
              }
              for (final cellIndex in union) {
                final currentCandidates = <int>{};
                for (var digit = 1; digit <= 9; digit++) {
                  if (grid.isCandidate(cellIndex, digit)) {
                    currentCandidates.add(digit);
                  }
                }
                final toRemove = currentCandidates
                    .where(toRemoveDigits.contains)
                    .toSet();
                if (toRemove.isNotEmpty) {
                  return [IndirectHint(cellIndex, toRemove.toList(), .hard)];
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
