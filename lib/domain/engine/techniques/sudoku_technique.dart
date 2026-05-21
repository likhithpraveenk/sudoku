import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

abstract class SudokuTechnique {
  Difficulty get level;

  List<Hint> getHints(SudokuGrid grid);
}
