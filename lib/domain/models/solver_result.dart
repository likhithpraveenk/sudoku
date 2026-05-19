import 'package:sudoku/domain/models/difficulty.dart';

/// Represents the diagnostic results of a logical Sudoku solver analysis.
///
/// This class holds structural metrics generated after running logical solving
/// passes, indicating:
/// * The highest difficulty level [highestDifficultyLevel] of any logical
///   technique required.
/// * The list of logical solving techniques [techniquesApplied] successfully
///   used.
/// * Whether backtracking search [bruteForceUsed] was needed because pure logic
///   was insufficient.
class SolverResult {
  /// Creates a new solver result instance.
  SolverResult({
    required this.highestDifficultyLevel,
    required this.techniquesApplied,
    required this.bruteForceUsed,
  });

  /// The maximum difficulty level of any technique applied to solve the grid.
  final Difficulty highestDifficultyLevel;

  /// The list of classes representing the solving techniques that were
  /// successfully applied.
  final List<Type> techniquesApplied;

  /// Indicates if backtracking search/brute force was required to complete the
  /// puzzle.
  final bool bruteForceUsed;

  /// Returns true if the puzzle was solved completely using pure logical
  /// inference rules.
  bool get isPureLogical => !bruteForceUsed;

  @override
  String toString() {
    return 'SolverResult('
        'difficulty: $highestDifficultyLevel, '
        'techniques: $techniquesApplied, '
        'bruteForce: $bruteForceUsed)';
  }
}
