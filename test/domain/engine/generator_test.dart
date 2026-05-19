import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/backtracker.dart';
import 'package:sudoku/domain/engine/generator.dart';
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

          final givenCount = puzzle.givenMask.where((e) => e).length;
          expect(givenCount, greaterThanOrEqualTo(20));
          expect(givenCount, lessThanOrEqualTo(40));

          final grid = SudokuGrid(values: puzzle.grid.values);
          expect(hasUniqueSolution(grid), isTrue);

          final solutionGrid = solveGrid(grid);
          expect(solutionGrid, isNotNull);

          for (var i = 0; i < 81; i++) {
            if (puzzle.givenMask[i]) {
              expect(puzzle.grid.values[i], equals(solutionGrid?.values[i]));
            }
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
