import 'package:flutter/foundation.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';

class IsolatePuzzleGeneratorService implements PuzzleGeneratorService {
  const IsolatePuzzleGeneratorService();

  @override
  Future<Puzzle> generate(Difficulty difficulty) {
    return compute(generatePuzzle, difficulty);
  }

  @override
  String get name => 'isolate_puzzle_generator';
}
