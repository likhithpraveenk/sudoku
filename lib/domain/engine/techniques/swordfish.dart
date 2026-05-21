import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class Swordfish implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var digit = 1; digit <= 9; digit++) {
      final rowCandidates = <int, List<int>>{};
      for (var row = 0; row < 9; row++) {
        final cols = <int>[];
        for (var col = 0; col < 9; col++) {
          final idx = row * 9 + col;
          if (grid.valueAt(idx) == 0 && grid.isCandidate(idx, digit)) {
            cols.add(col);
          }
        }
        if (cols.length >= 2 && cols.length <= 3) {
          rowCandidates[row] = cols;
        }
      }

      final rows = rowCandidates.keys.toList();
      if (rows.length >= 3) {
        for (var i = 0; i < rows.length - 2; i++) {
          for (var j = i + 1; j < rows.length - 1; j++) {
            for (var k = j + 1; k < rows.length; k++) {
              final r1 = rows[i];
              final r2 = rows[j];
              final r3 = rows[k];

              final unionCols = <int>{}
                ..addAll(rowCandidates[r1]!)
                ..addAll(rowCandidates[r2]!)
                ..addAll(rowCandidates[r3]!);

              if (unionCols.length == 3) {
                for (final col in unionCols) {
                  for (var row = 0; row < 9; row++) {
                    if (row != r1 && row != r2 && row != r3) {
                      final idx = row * 9 + col;
                      if (grid.valueAt(idx) == 0 &&
                          grid.isCandidate(idx, digit)) {
                        return [
                          IndirectHint(idx, [digit], Difficulty.hard),
                        ];
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (var digit = 1; digit <= 9; digit++) {
      final colCandidates = <int, List<int>>{};
      for (var col = 0; col < 9; col++) {
        final rows = <int>[];
        for (var row = 0; row < 9; row++) {
          final idx = row * 9 + col;
          if (grid.valueAt(idx) == 0 && grid.isCandidate(idx, digit)) {
            rows.add(row);
          }
        }
        if (rows.length >= 2 && rows.length <= 3) {
          colCandidates[col] = rows;
        }
      }

      final cols = colCandidates.keys.toList();
      if (cols.length >= 3) {
        for (var i = 0; i < cols.length - 2; i++) {
          for (var j = i + 1; j < cols.length - 1; j++) {
            for (var k = j + 1; k < cols.length; k++) {
              final c1 = cols[i];
              final c2 = cols[j];
              final c3 = cols[k];

              final unionRows = <int>{}
                ..addAll(colCandidates[c1]!)
                ..addAll(colCandidates[c2]!)
                ..addAll(colCandidates[c3]!);

              if (unionRows.length == 3) {
                for (final row in unionRows) {
                  for (var col = 0; col < 9; col++) {
                    if (col != c1 && col != c2 && col != c3) {
                      final idx = row * 9 + col;
                      if (grid.valueAt(idx) == 0 &&
                          grid.isCandidate(idx, digit)) {
                        return [
                          IndirectHint(idx, [digit], Difficulty.hard),
                        ];
                      }
                    }
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
