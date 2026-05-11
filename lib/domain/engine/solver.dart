import 'package:sudoku/domain/models/board.dart';

class Solver {
  const Solver();

  Board? solve(Board board) {
    final cells = List<int>.from(board.cells);
    final candidates = _buildCandidates(cells);
    return _search(cells, candidates, limit: 1) > 0 ? Board(cells) : null;
  }

  bool hasUniqueSolution(Board board) {
    final cells = List<int>.from(board.cells);
    final candidates = _buildCandidates(cells);
    return _search(cells, candidates, limit: 2) == 1;
  }

  int _search(
    List<int> cells,
    List<Set<int>> candidates, {
    required int limit,
  }) {
    if (_propagate(cells, candidates) == null) return 0;
    final index = _mrv(cells, candidates);
    if (index == -1) return 1;

    int count = 0;
    for (final digit in List<int>.from(candidates[index])) {
      final cellsCopy = limit == 1 ? cells : List<int>.from(cells);
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
    int best = -1, bestSize = 10;
    for (int i = 0; i < 81; i++) {
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
    bool progress = true;
    while (progress) {
      progress = false;
      for (int i = 0; i < 81; i++) {
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

  void _place(
    List<int> cells,
    List<Set<int>> candidates,
    int index,
    int digit,
  ) {
    candidates[index] = {};
    for (final p in _peers[index]) {
      candidates[p].remove(digit);
    }
  }

  List<Set<int>> _buildCandidates(List<int> cells) {
    return List.generate(81, (i) {
      if (cells[i] != 0) return <int>{};
      final used = <int>{};
      for (final p in _peers[i]) {
        if (cells[p] != 0) used.add(cells[p]);
      }
      return {1, 2, 3, 4, 5, 6, 7, 8, 9}..removeAll(used);
    });
  }

  List<Set<int>> _snapshot(List<Set<int>> candidates) => [
    for (final s in candidates) Set<int>.from(s),
  ];

  void _restore(List<Set<int>> candidates, List<Set<int>> snap) {
    for (int i = 0; i < 81; i++) {
      candidates[i] = snap[i];
    }
  }

  static final List<List<int>> _peers = List.generate(81, (i) {
    final r = i ~/ 9, c = i % 9;
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    final peers = <int>{};
    for (int x = 0; x < 9; x++) {
      peers.add(r * 9 + x);
      peers.add(x * 9 + c);
    }
    for (int dr = 0; dr < 3; dr++) {
      for (int dc = 0; dc < 3; dc++) {
        peers.add((br + dr) * 9 + (bc + dc));
      }
    }
    peers.remove(i);
    return peers.toList();
  });
}
