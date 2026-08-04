import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/engine/techniques/techniques.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/solver_result.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

SolverResult solveLogically(SudokuGrid grid) {
  final gridCopy = grid.clone();
  final techniquesApplied = <Type>[];
  var highestLevel = Difficulty.easy;
  bool progress;
  do {
    progress = false;
    for (final technique in allTechniques) {
      final hints = technique.getHints(gridCopy);
      if (hints.isNotEmpty) {
        hints[0].apply(gridCopy);
        techniquesApplied.add(technique.runtimeType);
        if (technique.level > highestLevel) {
          highestLevel = technique.level;
        }
        progress = true;
        break;
      }
    }
  } while (progress && !gridCopy.isSolved());

  final bruteForceUsed = !gridCopy.isSolved();
  if (bruteForceUsed) {
    _bruteForceSolve(gridCopy);
  }

  return SolverResult(
    highestDifficultyLevel: highestLevel,
    techniquesApplied: techniquesApplied,
    bruteForceUsed: bruteForceUsed,
    solvedGrid: gridCopy,
  );
}

bool _bruteForceSolve(SudokuGrid grid) {
  final emptyIndex = _findEmptyCell(grid);
  if (emptyIndex == -1) return true;

  for (var digit = 1; digit <= 9; digit++) {
    if (!grid.isCandidate(emptyIndex, digit)) continue;

    final peers = peersOf(emptyIndex);
    var valid = true;
    for (final peer in peers) {
      if (grid.valueAt(peer) == digit) {
        valid = false;
        break;
      }
    }
    if (!valid) continue;

    grid.setValue(emptyIndex, digit);
    if (_bruteForceSolve(grid)) return true;
    grid.clearValue(emptyIndex);
  }

  return false;
}

int _findEmptyCell(SudokuGrid grid) {
  for (var i = 0; i < 81; i++) {
    if (grid.valueAt(i) == 0) return i;
  }
  return -1;
}
