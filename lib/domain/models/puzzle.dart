import 'package:flutter/foundation.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

@immutable
class Puzzle {
  const Puzzle({required this.given, required this.solution});

  final SudokuGrid given;

  final SudokuGrid solution;

  bool isGivenAt(int index) => given.values[index] != 0;

  Puzzle copyWith({SudokuGrid? given, SudokuGrid? solution}) =>
      Puzzle(given: given ?? this.given, solution: solution ?? this.solution);

  @override
  bool operator ==(Object other) =>
      other is Puzzle && given == other.given && solution == other.solution;

  @override
  int get hashCode => Object.hash(given, solution);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('=== Puzzle Grid ===')
      ..write(given.toString())
      ..writeln('\n=== Puzzle Solution ===')
      ..write(solution.toString());
    return buffer.toString();
  }
}
