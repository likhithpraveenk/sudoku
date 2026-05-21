import 'package:flutter/foundation.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';

abstract class PuzzleGeneratorService {
  Future<Puzzle> generate(Difficulty difficulty);

  String get name;
}

class IsolatePuzzleGeneratorService implements PuzzleGeneratorService {
  const IsolatePuzzleGeneratorService();

  @override
  Future<Puzzle> generate(Difficulty difficulty) {
    return compute(generatePuzzle, difficulty);
  }

  @override
  String get name => 'isolate';
}
