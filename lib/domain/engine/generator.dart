import 'dart:math';

import 'package:sudoku/domain/engine/grid_builder.dart';
import 'package:sudoku/domain/engine/has_unique_solution.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/engine/techniques/techniques.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

int noOfCluesForDifficulty(Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => 36,
  Difficulty.medium => 30,
  Difficulty.hard => 24,
  Difficulty.expert => 20,
};

class Generator {
  Generator({Random? random})
    : _builder = GridBuilder(random: random),
      _random = random ?? Random();

  final GridBuilder _builder;
  final Random _random;

  Puzzle _generate(Difficulty difficulty) {
    final solution = _builder.build();
    while (true) {
      final puzzle = _digHoles(SudokuGrid(values: solution.values), difficulty);
      if (puzzle != null) {
        return Puzzle(
          given: SudokuGrid(values: puzzle.values),
          solution: solution,
        );
      }
    }
  }

  SudokuGrid? _digHoles(SudokuGrid solution, Difficulty difficulty) {
    final cells = List<int>.from(solution.values);
    final indices = List.generate(81, (i) => i)..shuffle(_random);

    final targetClues = noOfCluesForDifficulty(difficulty);

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
    final result = solveLogically(grid);

    if (difficulty == .expert && result.bruteForceUsed) return true;

    if (difficulty == .expert) {
      final startNaked = NakedSingle().getHints(grid).length;
      final startHidden = HiddenSingle().getHints(grid).length;

      return (result.highestDifficultyLevel == .expert ||
              result.highestDifficultyLevel == .hard) &&
          (startNaked + startHidden <= 2);
    }

    if (difficulty == .hard) {
      final startNaked = NakedSingle().getHints(grid).length;
      final startHidden = HiddenSingle().getHints(grid).length;

      return result.highestDifficultyLevel == .hard &&
          (startNaked + startHidden <= 3);
    }

    return result.highestDifficultyLevel == difficulty;
  }
}

Puzzle generatePuzzle(Difficulty difficulty) =>
    Generator()._generate(difficulty);
