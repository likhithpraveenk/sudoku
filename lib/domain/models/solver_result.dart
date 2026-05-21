import 'package:sudoku/domain/models/difficulty.dart';

class SolverResult {
  SolverResult({
    required this.highestDifficultyLevel,
    required this.techniquesApplied,
    required this.bruteForceUsed,
  });

  final Difficulty highestDifficultyLevel;

  final List<Type> techniquesApplied;

  final bool bruteForceUsed;

  @override
  String toString() {
    return 'SolverResult('
        'difficulty: $highestDifficultyLevel, '
        'techniques: $techniquesApplied, '
        'bruteForce: $bruteForceUsed)';
  }
}
