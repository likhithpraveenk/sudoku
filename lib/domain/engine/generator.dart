import 'dart:math';

import 'package:sudoku/domain/engine/backtracker.dart';
import 'package:sudoku/domain/engine/grid_builder.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/engine/techniques/techniques.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// A high-performance Sudoku puzzle generator.
///
/// This class handles generating valid, fully-solved 9x9 solution grids using
/// [GridBuilder], digging holes/cells to form a puzzle using backtracking,
/// validating that the resulting puzzle has a unique correct solution, and
/// verifying that the logical difficulty matches the target [Difficulty].
class Generator {
  /// Creates a new puzzle generator instance.
  Generator({Random? random})
    : _builder = GridBuilder(random: random),
      _random = random ?? Random();

  final GridBuilder _builder;
  final Random _random;

  Puzzle _generate(Difficulty difficulty) {
    while (true) {
      final solution = _builder.build();
      final puzzle = _digHoles(SudokuGrid(values: solution.values), difficulty);
      if (puzzle != null) {
        final mask = List.generate(81, (i) => puzzle.valueAt(i) != 0);
        return Puzzle(
          grid: SudokuGrid(values: puzzle.values),
          solution: solution,
          givenMask: mask,
        );
      }
    }
  }

  SudokuGrid? _digHoles(SudokuGrid solution, Difficulty difficulty) {
    final cells = List<int>.from(solution.values);
    final indices = List.generate(81, (i) => i)..shuffle(_random);

    final targetClues = switch (difficulty) {
      Difficulty.easy => 36,
      Difficulty.medium => 30,
      Difficulty.hard => 24,
      Difficulty.expert => 20,
    };

    var count = 81;
    for (final index in indices) {
      if (count <= targetClues) break;
      final backup = cells[index];
      cells[index] = 0;
      final grid = SudokuGrid(values: cells);
      if (!hasUniqueSolution(grid)) {
        cells[index] = backup;
      } else {
        count--;
      }
    }

    final grid = SudokuGrid(values: cells);
    return _meetsTargetDifficulty(grid, difficulty) ? grid : null;
  }

  bool _meetsTargetDifficulty(SudokuGrid grid, Difficulty difficulty) {
    final result = SudokuSolver().solveLogically(grid);
    if (!result.isPureLogical) return false;

    if (difficulty == Difficulty.expert) {
      final startNaked = NakedSingle().getHints(grid).length;
      final startHidden = HiddenSingle().getHints(grid).length;

      // For expert difficulty, require high logical techniques (hard or expert)
      // and ensure there are very few (at most 2) simple singles available
      // at the start
      return (result.highestDifficultyLevel == Difficulty.expert ||
              result.highestDifficultyLevel == Difficulty.hard) &&
          (startNaked + startHidden <= 2);
    }

    if (difficulty == Difficulty.hard) {
      final startNaked = NakedSingle().getHints(grid).length;
      final startHidden = HiddenSingle().getHints(grid).length;

      // For hard difficulty, require hard logical techniques
      // and ensure there are very few (at most 3) simple singles available
      // at the start
      return result.highestDifficultyLevel == Difficulty.hard &&
          (startNaked + startHidden <= 3);
    }

    return result.highestDifficultyLevel == difficulty;
  }
}

/// Generates a valid, unique Sudoku puzzle matching the requested [difficulty].
Puzzle generatePuzzle(Difficulty difficulty) =>
    Generator()._generate(difficulty);
