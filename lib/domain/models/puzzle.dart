import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';

class Puzzle {
  final Board board;
  final Board solution;
  final List<bool> givenMask;

  const Puzzle({
    required this.board,
    required this.solution,
    required this.givenMask,
  }) : assert(givenMask.length == 81);

  bool isGivenCell(Cell cell) => givenMask[cell.index];

  bool isGivenAt(int index) => givenMask[index];

  Puzzle copyWith({Board? board, Board? solution, List<bool>? givenMask}) =>
      Puzzle(
        board: board ?? this.board,
        solution: solution ?? this.solution,
        givenMask: givenMask ?? this.givenMask,
      );

  Set<Cell> get givenCells => {
    for (int i = 0; i < 81; i++)
      if (givenMask[i]) Cell.fromIndex(i),
  };

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Puzzle &&
      board == other.board &&
      solution == other.solution &&
      _listEquals(givenMask, other.givenMask);

  @override
  int get hashCode => Object.hash(board, solution, Object.hashAll(givenMask));

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Puzzle Board ===');
    buffer.write(board.toString());
    buffer.writeln('\n=== Puzzle Solution ===');
    buffer.write(solution.toString());
    buffer.writeln('\n=== Given Mask (true = fixed clue) ===');
    buffer.write(_maskToString());
    return buffer.toString();
  }

  String _maskToString() {
    final buffer = StringBuffer();
    for (int row = 0; row < 9; row++) {
      if (row % 3 == 0 && row != 0) buffer.writeln('------+-------+------');
      for (int col = 0; col < 9; col++) {
        if (col % 3 == 0 && col != 0) buffer.write('| ');
        final index = row * 9 + col;
        buffer.write(givenMask[index] ? 'X ' : '. ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
