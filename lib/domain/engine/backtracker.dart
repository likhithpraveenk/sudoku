import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// The [hasUniqueSolution] method.
bool hasUniqueSolution(SudokuGrid grid) {
  final cells = List<int>.from(grid.values);
  final candidates = _buildCandidates(cells);
  return _search(cells, candidates, limit: 2) == 1;
}

/// The [countSolutions] method.
int countSolutions(SudokuGrid grid, {int limit = 2}) {
  final cells = List<int>.from(grid.values);
  final candidates = _buildCandidates(cells);
  return _search(cells, candidates, limit: limit);
}

/// A public member.
SudokuGrid? solveGrid(SudokuGrid grid) {
  final cells = List<int>.from(grid.values);
  final candidates = _buildCandidates(cells);
  final success = _search(cells, candidates, limit: 1) > 0;
  return success ? SudokuGrid(values: cells) : null;
}

List<Set<int>> _buildCandidates(List<int> cells) {
  return List.generate(81, (i) {
    if (cells[i] != 0) return <int>{};
    final used = <int>{};
    for (final p in kGridPeers[i]) {
      if (cells[p] != 0) used.add(cells[p]);
    }
    return {1, 2, 3, 4, 5, 6, 7, 8, 9}..removeAll(used);
  });
}

int _search(List<int> cells, List<Set<int>> candidates, {required int limit}) {
  if (_propagate(cells, candidates) == null) return 0;
  final index = _mrv(cells, candidates);
  if (index == -1) return 1;

  var count = 0;
  for (final digit in List<int>.from(candidates[index])) {
    final cellsCopy = List<int>.from(cells);
    final snap = _snapshot(candidates);
    cellsCopy[index] = digit;
    _place(cellsCopy, candidates, index, digit);
    count += _search(cellsCopy, candidates, limit: limit);
    if (limit == 1 && count > 0) {
      return count;
    }
    _restore(candidates, snap);
    if (count >= limit) return count;
  }
  return count;
}

int _mrv(List<int> cells, List<Set<int>> candidates) {
  var best = -1;
  var bestSize = 10;
  for (var i = 0; i < 81; i++) {
    if (cells[i] != 0) continue;
    final s = candidates[i].length;
    if (s < bestSize) {
      bestSize = s;
      best = i;
      if (s == 1) break;
    }
  }
  return best;
}

List<int>? _propagate(List<int> cells, List<Set<int>> candidates) {
  final filled = <int>[];
  var progress = true;
  while (progress) {
    progress = false;
    for (var i = 0; i < 81; i++) {
      if (cells[i] != 0) continue;
      if (candidates[i].isEmpty) return null;
      if (candidates[i].length == 1) {
        final digit = candidates[i].first;
        cells[i] = digit;
        _place(cells, candidates, i, digit);
        filled.add(i);
        progress = true;
      }
    }
  }
  return filled;
}

void _place(List<int> cells, List<Set<int>> candidates, int index, int digit) {
  candidates[index] = {};
  for (final p in kGridPeers[index]) {
    candidates[p].remove(digit);
  }
}

List<Set<int>> _snapshot(List<Set<int>> candidates) => [
  for (final s in candidates) Set<int>.from(s),
];

void _restore(List<Set<int>> candidates, List<Set<int>> snap) {
  for (var i = 0; i < 81; i++) {
    candidates[i] = snap[i];
  }
}
