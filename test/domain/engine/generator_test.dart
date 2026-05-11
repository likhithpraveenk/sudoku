import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/puzzle.dart';

void main() {
  group('Generator', () {
    late Generator generator;

    setUp(() {
      generator = Generator(const Solver());
    });

    test('generates a valid puzzle for each difficulty', () {
      for (final difficulty in Difficulty.values) {
        final puzzle = generator.generate(difficulty);
        expect(puzzle, isA<Puzzle>());

        final givenCount = puzzle.givenMask.where((element) => element).length;

        expect(givenCount, greaterThanOrEqualTo(20));
        expect(givenCount, lessThanOrEqualTo(40));

        const solver = Solver();
        final solved = solver.solve(puzzle.board);
        expect(solved, isNotNull);

        for (int i = 0; i < 81; i++) {
          if (puzzle.givenMask[i]) {
            expect(puzzle.board.cells[i], equals(solved?.cells[i]));
          }
        }
      }
    });

    test('generator respects custom presets map', () {
      final customPresets = {Difficulty.easy: 20};
      final generator = Generator(const Solver(), presets: customPresets);
      final puzzle = generator.generate(.easy);
      final givenCount = puzzle.givenMask.where((element) => element).length;

      expect(givenCount, greaterThanOrEqualTo(15));
      expect(givenCount, lessThanOrEqualTo(25));
    });
  });
}
