import 'package:sudoku/domain/engine/techniques/claiming_pairs.dart';
import 'package:sudoku/domain/engine/techniques/hidden_pair.dart';
import 'package:sudoku/domain/engine/techniques/hidden_quad.dart';
import 'package:sudoku/domain/engine/techniques/hidden_single.dart';
import 'package:sudoku/domain/engine/techniques/hidden_triple.dart';
import 'package:sudoku/domain/engine/techniques/jellyfish.dart';
import 'package:sudoku/domain/engine/techniques/naked_pair.dart';
import 'package:sudoku/domain/engine/techniques/naked_quad.dart';
import 'package:sudoku/domain/engine/techniques/naked_single.dart';
import 'package:sudoku/domain/engine/techniques/naked_triple.dart';
import 'package:sudoku/domain/engine/techniques/pointing_pairs.dart';
import 'package:sudoku/domain/engine/techniques/simple_coloring.dart';
import 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
import 'package:sudoku/domain/engine/techniques/swordfish.dart';
import 'package:sudoku/domain/engine/techniques/turbot_fish.dart';
import 'package:sudoku/domain/engine/techniques/x_wing.dart';
import 'package:sudoku/domain/engine/techniques/x_y_wing.dart';
import 'package:sudoku/domain/engine/techniques/xyz_wing.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

export 'package:sudoku/domain/engine/techniques/claiming_pairs.dart';
export 'package:sudoku/domain/engine/techniques/hidden_pair.dart';
export 'package:sudoku/domain/engine/techniques/hidden_quad.dart';
export 'package:sudoku/domain/engine/techniques/hidden_single.dart';
export 'package:sudoku/domain/engine/techniques/hidden_triple.dart';
export 'package:sudoku/domain/engine/techniques/jellyfish.dart';
export 'package:sudoku/domain/engine/techniques/naked_pair.dart';
export 'package:sudoku/domain/engine/techniques/naked_quad.dart';
export 'package:sudoku/domain/engine/techniques/naked_single.dart';
export 'package:sudoku/domain/engine/techniques/naked_triple.dart';
export 'package:sudoku/domain/engine/techniques/pointing_pairs.dart';
export 'package:sudoku/domain/engine/techniques/simple_coloring.dart';
export 'package:sudoku/domain/engine/techniques/sudoku_technique.dart';
export 'package:sudoku/domain/engine/techniques/swordfish.dart';
export 'package:sudoku/domain/engine/techniques/turbot_fish.dart';
export 'package:sudoku/domain/engine/techniques/x_wing.dart';
export 'package:sudoku/domain/engine/techniques/x_y_wing.dart';
export 'package:sudoku/domain/engine/techniques/xyz_wing.dart';

/// A public member.
List<SudokuTechnique> techniquesUpTo(Difficulty d) => switch (d) {
  .easy => [NakedSingle(), HiddenSingle()],
  .medium => [
    NakedSingle(),
    HiddenSingle(),
    PointingPairs(),
    ClaimingPairs(),
    NakedPair(),
    HiddenPair(),
  ],
  .hard => [
    NakedSingle(),
    HiddenSingle(),
    PointingPairs(),
    ClaimingPairs(),
    NakedPair(),
    HiddenPair(),
    XWing(),
    NakedTriple(),
    HiddenTriple(),
    XYWing(),
    Swordfish(),
  ],
  .expert => [
    NakedSingle(),
    HiddenSingle(),
    PointingPairs(),
    ClaimingPairs(),
    NakedPair(),
    HiddenPair(),
    XWing(),
    NakedTriple(),
    HiddenTriple(),
    XYWing(),
    Swordfish(),
    SimpleColoring(),
    XYZWing(),
    Jellyfish(),
    NakedQuad(),
    HiddenQuad(),
    TurbotFish(),
  ],
};

/// The [canSolveHumanly] method.
bool canSolveHumanly(SudokuGrid grid, List<SudokuTechnique> techniques) {
  final gridCopy = grid.clone();
  while (true) {
    if (gridCopy.isSolved()) return true;
    var progress = false;
    for (final technique in techniques) {
      final hints = technique.getHints(gridCopy);
      if (hints.isNotEmpty) {
        hints[0].apply(gridCopy);
        progress = true;
        break;
      }
    }
    if (!progress) return false;
  }
}
