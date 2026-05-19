import 'package:flutter/foundation.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// Represents an immutable template for a single Sudoku puzzle match.
///
/// This class encapsulates:
/// * The starting board state [grid] containing given clues and empty cells.
/// * The solved board state [solution] representing the correct, fully-solved
///   grid.
/// * The [givenMask], an 81-element boolean list indicating which cell indices
///   were part of the starting clue set and are therefore locked and immutable.
@immutable
class Puzzle {
  /// Creates a new puzzle template with locked starting clues, the correct
  /// solution, and the initial grid.
  const Puzzle({
    required this.grid,
    required this.solution,
    required this.givenMask,
  }) : assert(givenMask.length == 81, 'Given mask must have length 81');

  /// The initial board state containing the starting clues.
  final SudokuGrid grid;

  /// The correct, unique solved configuration of this Sudoku grid.
  final SudokuGrid solution;

  /// An 81-element list indicating whether the cell at each index is a locked
  /// clue (true).
  final List<bool> givenMask;

  /// Returns true if the cell at [index] is part of the locked starting clues.
  bool isGivenAt(int index) => givenMask[index];

  /// Returns a copy of this puzzle with updated fields.
  Puzzle copyWith({
    SudokuGrid? grid,
    SudokuGrid? solution,
    List<bool>? givenMask,
  }) => Puzzle(
    grid: grid ?? this.grid,
    solution: solution ?? this.solution,
    givenMask: givenMask ?? this.givenMask,
  );

  /// Returns a set containing the cell indices of all starting clues.
  Set<int> get givenIndices => {
    for (int i = 0; i < 81; i++)
      if (givenMask[i]) i,
  };

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Puzzle &&
      grid == other.grid &&
      solution == other.solution &&
      _listEquals(givenMask, other.givenMask);

  @override
  int get hashCode => Object.hash(grid, solution, Object.hashAll(givenMask));

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('=== Puzzle Grid ===')
      ..write(grid.toString81())
      ..writeln('\n=== Puzzle Solution ===')
      ..write(solution.toString81())
      ..writeln('\n=== Given Mask (true = fixed clue) ===')
      ..write(_maskToString());
    return buffer.toString();
  }

  String _maskToString() {
    final buffer = StringBuffer();
    for (var row = 0; row < 9; row++) {
      if (row % 3 == 0 && row != 0) buffer.writeln('------+-------+------');
      for (var col = 0; col < 9; col++) {
        if (col % 3 == 0 && col != 0) buffer.write('| ');
        final index = row * 9 + col;
        buffer.write(givenMask[index] ? 'X ' : '. ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
