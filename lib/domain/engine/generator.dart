import 'dart:math';

import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';

class Generator {
  Generator(this._solver, {Random? random, Map<Difficulty, int>? presets})
    : _random = random ?? Random(),
      _presets = presets ?? {.easy: 36, .medium: 30, .hard: 26, .expert: 22};

  final Solver _solver;
  final Random _random;
  final Map<Difficulty, int> _presets;

  Puzzle generate(Difficulty difficulty) {
    final solution = _buildFilledGrid();
    final puzzle = _digHoles(solution, _presets[difficulty]!);
    final mask = List.generate(81, (i) => puzzle.cells[i] != 0);

    return Puzzle(board: puzzle, solution: solution, givenMask: mask);
  }

  Board _buildFilledGrid() {
    final cells = List<int>.filled(81, 0);
    _fillBacktrack(cells);
    return Board(cells);
  }

  bool _fillBacktrack(List<int> cells) {
    final empty = cells.indexOf(0);
    if (empty == -1) return true;

    final digits = List.generate(9, (i) => i + 1)..shuffle(_random);
    final cell = Cell.fromIndex(empty);

    for (final digit in digits) {
      if (_isValid(cells, cell, digit)) {
        cells[empty] = digit;
        if (_fillBacktrack(cells)) return true;
        cells[empty] = 0;
      }
    }
    return false;
  }

  Board _digHoles(Board solution, int preset) {
    final cells = List<int>.from(solution.cells);
    final indices = List.generate(81, (i) => i)..shuffle(_random);

    int count = 81;
    for (final index in indices) {
      if (count <= preset) break;

      final backup = cells[index];
      cells[index] = 0;

      if (!_solver.hasUniqueSolution(Board(cells))) {
        cells[index] = backup;
      } else {
        count--;
      }
    }

    return Board(cells);
  }

  bool _isValid(List<int> cells, Cell cell, int digit) {
    final r = cell.row, c = cell.col;
    for (int i = 0; i < 9; i++) {
      if (i != c && cells[r * 9 + i] == digit) return false;
      if (i != r && cells[i * 9 + c] == digit) return false;
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int dr = 0; dr < 3; dr++) {
      for (int dc = 0; dc < 3; dc++) {
        final nr = br + dr, nc = bc + dc;
        if (nr == r && nc == c) continue;
        if (cells[nr * 9 + nc] == digit) return false;
      }
    }
    return true;
  }
}
