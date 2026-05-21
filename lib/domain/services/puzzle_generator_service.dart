import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';

abstract class PuzzleGeneratorService {
  Future<Puzzle> generate(Difficulty difficulty);

  String get name;
}
