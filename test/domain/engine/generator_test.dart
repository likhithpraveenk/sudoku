import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/engine/has_unique_solution.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

void main() {
  group('Puzzle generation', () {
    test(
      'generates a valid puzzle for each difficulty',
      () {
        for (final difficulty in Difficulty.values) {
          final puzzle = generatePuzzle(difficulty);
          expect(puzzle, isA<Puzzle>());

          final grid = SudokuGrid(values: puzzle.given.values);
          expect(hasUniqueSolution(grid), isTrue);

          final solutionGrid = solveGrid(grid);
          expect(solutionGrid, isNotNull);

          for (var i = 0; i < 81; i++) {
            final value = puzzle.given.values[i];
            if (value != 0) {
              expect(value, equals(solutionGrid?.values[i]));
            }
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
