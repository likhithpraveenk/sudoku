import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/board.dart';

import '../../helpers/sudoku_boards.dart';

void main() {
  group('Solver', () {
    late Solver solver;

    setUp(() {
      solver = const Solver();
    });

    test('solves a simple puzzle', () {
      final board = TestBoards.simplePuzzle();
      final solved = solver.solve(board);

      expect(solved, isNotNull);
      expect(solved?.cells.every((element) => element != 0), isTrue);
    });

    test('returns null for unsolvable puzzle', () {
      final unsolvableBoard = TestBoards.unsolvableBoard();
      final solved = solver.solve(unsolvableBoard);

      expect(solved, isNull);
    });

    test('hasUniqueSolution returns true for a puzzle with one solution', () {
      final board = TestBoards.simplePuzzle();

      expect(solver.hasUniqueSolution(board), isTrue);
    });

    test(
      'hasUniqueSolution returns false for a puzzle with more than one solution',
      () {
        final emptyBoard = Board.empty;

        expect(solver.hasUniqueSolution(emptyBoard), isFalse);
      },
    );
  });
}
