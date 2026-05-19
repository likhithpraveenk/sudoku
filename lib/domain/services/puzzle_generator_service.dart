import 'package:flutter/foundation.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';

/// Service interface for generating Sudoku puzzles.
abstract class PuzzleGeneratorService {
  /// Generates a Sudoku puzzle of the specified difficulty.
  Future<Puzzle> generate(Difficulty difficulty);

  /// The name/identifier of this generator service.
  String get name;
}

/// An implementation of [PuzzleGeneratorService] that generates puzzles
/// on a background isolate to keep the UI smooth and responsive.
class IsolatePuzzleGeneratorService implements PuzzleGeneratorService {
  /// Creates a const [IsolatePuzzleGeneratorService] instance.
  const IsolatePuzzleGeneratorService();

  @override
  Future<Puzzle> generate(Difficulty difficulty) {
    return compute(generatePuzzle, difficulty);
  }

  @override
  String get name => 'isolate';
}
