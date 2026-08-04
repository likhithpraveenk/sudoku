import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

class SolverResult {
  SolverResult({
    required this.highestDifficultyLevel,
    required this.techniquesApplied,
    required this.bruteForceUsed,
    required this.solvedGrid,
  });

  final Difficulty highestDifficultyLevel;

  final List<Type> techniquesApplied;

  final bool bruteForceUsed;

  final SudokuGrid solvedGrid;

  @override
  String toString() {
    return 'SolverResult '
        'difficulty: $highestDifficultyLevel, '
        'techniques: $techniquesApplied, '
        'bruteForce: $bruteForceUsed\n'
        'solvedGrid: $solvedGrid';
  }
}
