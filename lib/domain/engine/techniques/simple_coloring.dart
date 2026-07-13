import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class SimpleColoring implements SudokuTechnique {
  @override
  Difficulty get level => .hard;

  @override
  List<Hint> getHints(SudokuGrid grid) {
    for (var digit = 1; digit <= 9; digit++) {
      final adj = <int, List<int>>{};
      for (final unit in kGridUnits) {
        final spots = <int>[];
        for (final idx in unit) {
          if (grid.valueAt(idx) == 0 && grid.isCandidate(idx, digit)) {
            spots.add(idx);
          }
        }
        if (spots.length == 2) {
          final a = spots[0];
          final b = spots[1];
          adj.putIfAbsent(a, () => []).add(b);
          adj.putIfAbsent(b, () => []).add(a);
        }
      }

      if (adj.isEmpty) continue;

      final colored = <int>{};
      final colorMap = <int, int>{};

      for (final start in adj.keys) {
        if (colored.contains(start)) continue;

        final queue = <int>[start];
        colorMap[start] = 0;
        colored.add(start);
        var head = 0;
        var conflict = false;
        while (head < queue.length) {
          final cur = queue[head++];
          final curColor = colorMap[cur]!;
          for (final nb in adj[cur] ?? <int>[]) {
            if (colored.contains(nb)) {
              if (colorMap[nb] == curColor) conflict = true;
            } else {
              colorMap[nb] = 1 - curColor;
              colored.add(nb);
              queue.add(nb);
            }
          }
        }

        if (conflict) {
          for (var col = 0; col <= 1; col++) {
            final cellsOfColor = <int>[];
            for (final idx in queue) {
              if (colorMap[idx] == col) cellsOfColor.add(idx);
            }
            var intraConflict = false;
            for (var i = 0; i < cellsOfColor.length && !intraConflict; i++) {
              for (var j = i + 1; j < cellsOfColor.length; j++) {
                if (isPeer(cellsOfColor[i], cellsOfColor[j])) {
                  intraConflict = true;
                  break;
                }
              }
            }
            if (intraConflict) {
              for (final idx in cellsOfColor) {
                return [
                  IndirectHint(idx, [digit], .expert),
                ];
              }
            }
          }
        } else {
          final color0Cells = queue.where((idx) => colorMap[idx] == 0).toSet();
          final color1Cells = queue.where((idx) => colorMap[idx] == 1).toSet();

          for (var i = 0; i < 81; i++) {
            if (grid.valueAt(i) != 0 || !grid.isCandidate(i, digit)) continue;
            if (colored.contains(i)) continue;
            var sees0 = false;
            var sees1 = false;
            for (final p in kGridPeers[i]) {
              if (color0Cells.contains(p)) sees0 = true;
              if (color1Cells.contains(p)) sees1 = true;
              if (sees0 && sees1) break;
            }
            if (sees0 && sees1) {
              return [
                IndirectHint(i, [digit], .expert),
              ];
            }
          }
        }
      }
    }
    return [];
  }
}
