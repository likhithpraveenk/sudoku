import 'package:sudoku/domain/engine/techniques/techniques.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/solver_result.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// [SudokuSolver] definition.
class SudokuSolver {
  /// Constructor for [SudokuSolver].
  SudokuSolver() : _allTechniques = _getAllTechniquesSortedByLevel();
  final List<SudokuTechnique> _allTechniques;

  static List<SudokuTechnique> _getAllTechniquesSortedByLevel() {
    final techniques = <SudokuTechnique>[
      NakedSingle(),
      HiddenSingle(),
      PointingPairs(),
      ClaimingPairs(),
      NakedPair(),
      HiddenPair(),
      NakedTriple(),
      HiddenTriple(),
      XWing(),
      XYWing(),
      Swordfish(),
      NakedQuad(),
      SimpleColoring(),
      TurbotFish(),
      XYZWing(),
      Jellyfish(),
      HiddenQuad(),
    ]..sort((a, b) => a.level.compareTo(b.level));
    return techniques;
  }

  /// Solve the grid using only logical techniques (no guessing).
  /// Returns a [SolverResult] with the highest difficulty level used
  /// and the list of techniques applied.
  SolverResult solveLogically(SudokuGrid grid) {
    final gridCopy = grid.clone();
    final techniquesApplied = <Type>[];
    var highestLevel = Difficulty.easy; // start with lowest
    bool progress;
    do {
      progress = false;
      for (final technique in _allTechniques) {
        final hints = technique.getHints(gridCopy);
        if (hints.isNotEmpty) {
          // Apply the first hint
          hints[0].apply(gridCopy);
          techniquesApplied.add(technique.runtimeType);
          final mappedIndex = technique.level - 1;
          if (mappedIndex > highestLevel.index) {
            highestLevel = Difficulty.values[mappedIndex];
          }
          progress = true;
          break; // restart from the lowest level technique after each hint
        }
      }
    } while (progress && !gridCopy.isSolved());

    final bruteForceUsed = !gridCopy.isSolved();
    return SolverResult(
      highestDifficultyLevel: highestLevel,
      techniquesApplied: techniquesApplied,
      bruteForceUsed: bruteForceUsed,
    );
  }

  /// Get a single hint for the grid using the lowest level technique available.
  /// Returns null if no hint is available (grid is solved or requires
  /// guessing).
  Hint? getSingleHint(SudokuGrid grid) {
    final gridCopy = grid.clone();
    for (final technique in _allTechniques) {
      final hints = technique.getHints(gridCopy);
      if (hints.isNotEmpty) {
        return hints[0];
      }
    }
    return null;
  }
}
