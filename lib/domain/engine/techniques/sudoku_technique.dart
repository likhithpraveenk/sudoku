import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// A public member.
abstract class SudokuTechnique {
  /// The [level] getter.
  int get level;

  /// A public member.
  List<Hint> getHints(SudokuGrid grid);
}
