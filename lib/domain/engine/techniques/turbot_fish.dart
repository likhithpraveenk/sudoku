import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [TurbotFish] definition.
class TurbotFish implements SudokuTechnique {
  @override
  int get level => 3;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var digit = 1; digit <= 9; digit++) {
      // Row-based Skyscraper
      final rowCandidates = <int, List<int>>{};
      for (var row = 0; row < 9; row++) {
        final cols = <int>[];
        for (var col = 0; col < 9; col++) {
          final idx = row * 9 + col;
          if (grid.valueAt(idx) == 0 && grid.isCandidate(idx, digit)) {
            cols.add(col);
          }
        }
        if (cols.length == 2) {
          rowCandidates[row] = cols;
        }
      }

      final rows = rowCandidates.keys.toList();
      for (var i = 0; i < rows.length; i++) {
        for (var j = i + 1; j < rows.length; j++) {
          final r1 = rows[i];
          final r2 = rows[j];
          final cols1 = rowCandidates[r1]!;
          final cols2 = rowCandidates[r2]!;

          // Check if they share exactly one column
          final shared = cols1.toSet().intersection(cols2.toSet());
          if (shared.length == 1) {
            final baseCol = shared.first;
            final tipCol1 = cols1.first == baseCol ? cols1.last : cols1.first;
            final tipCol2 = cols2.first == baseCol ? cols2.last : cols2.first;

            final tip1 = r1 * 9 + tipCol1;
            final tip2 = r2 * 9 + tipCol2;

            // Target cells see both tips
            for (var target = 0; target < 81; target++) {
              if (target == tip1 || target == tip2) continue;
              if (grid.valueAt(target) != 0) continue;
              if (kGridPeerSets[tip1].contains(target) &&
                  kGridPeerSets[tip2].contains(target) &&
                  grid.isCandidate(target, digit)) {
                return [
                  IndirectHint(target, [digit], Difficulty.expert),
                ];
              }
            }
          }
        }
      }

      // Column-based Skyscraper
      final colCandidates = <int, List<int>>{};
      for (var col = 0; col < 9; col++) {
        final rows = <int>[];
        for (var row = 0; row < 9; row++) {
          final idx = row * 9 + col;
          if (grid.valueAt(idx) == 0 && grid.isCandidate(idx, digit)) {
            rows.add(row);
          }
        }
        if (rows.length == 2) {
          colCandidates[col] = rows;
        }
      }

      final cols = colCandidates.keys.toList();
      for (var i = 0; i < cols.length; i++) {
        for (var j = i + 1; j < cols.length; j++) {
          final c1 = cols[i];
          final c2 = cols[j];
          final rows1 = colCandidates[c1]!;
          final rows2 = colCandidates[c2]!;

          // Check if they share exactly one row
          final shared = rows1.toSet().intersection(rows2.toSet());
          if (shared.length == 1) {
            final baseRow = shared.first;
            final tipRow1 = rows1.first == baseRow ? rows1.last : rows1.first;
            final tipRow2 = rows2.first == baseRow ? rows2.last : rows2.first;

            final tip1 = tipRow1 * 9 + c1;
            final tip2 = tipRow2 * 9 + c2;

            // Target cells see both tips
            for (var target = 0; target < 81; target++) {
              if (target == tip1 || target == tip2) continue;
              if (grid.valueAt(target) != 0) continue;
              if (kGridPeerSets[tip1].contains(target) &&
                  kGridPeerSets[tip2].contains(target) &&
                  grid.isCandidate(target, digit)) {
                return [
                  IndirectHint(target, [digit], Difficulty.expert),
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
