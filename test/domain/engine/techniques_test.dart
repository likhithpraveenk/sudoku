import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/techniques/techniques.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

void main() {
  group('Advanced Solving Techniques', () {
    test('All techniques return empty on a solved grid', () {
      final solvedValues = List.generate(81, (i) => ((i ~/ 9 + i % 9) % 9) + 1);
      final solvedGrid = SudokuGrid(values: solvedValues);

      final allTechniques = <SudokuTechnique>[
        NakedSingle(),
        HiddenSingle(),
        PointingPairs(),
        ClaimingPairs(),
        NakedPair(),
        HiddenPair(),
        NakedTriple(),
        HiddenTriple(),
        XWing(),
        XYWing(),
        Swordfish(),
        XYZWing(),
        Jellyfish(),
        NakedQuad(),
        HiddenQuad(),
        TurbotFish(),
        SimpleColoring(),
      ];

      for (final technique in allTechniques) {
        expect(
          technique.getHints(solvedGrid),
          isEmpty,
          reason:
              '${technique.runtimeType} should return empty on a solved grid',
        );
      }
    });

    group('HiddenTriple', () {
      test('ignores units where one of the target digits is already solved '
          '(bug fix validation)', () {
        final grid = SudokuGrid()..setValue(8, 1);

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(0, d)) grid.removeCandidate(0, d);
        }
        grid
          ..addCandidate(0, 2)
          ..addCandidate(0, 4);

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(1, d)) grid.removeCandidate(1, d);
        }
        grid
          ..addCandidate(1, 3)
          ..addCandidate(1, 5);

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(2, d)) grid.removeCandidate(2, d);
        }
        grid
          ..addCandidate(2, 2)
          ..addCandidate(2, 3)
          ..addCandidate(2, 6);

        for (var i = 3; i < 8; i++) {
          if (grid.isCandidate(i, 2)) grid.removeCandidate(i, 2);
          if (grid.isCandidate(i, 3)) grid.removeCandidate(i, 3);
        }

        final hiddenTriple = HiddenTriple();

        expect(hiddenTriple.getHints(grid), isEmpty);
      });

      test('correctly identifies a valid hidden triple and eliminates '
          'other candidates', () {
        final grid = SudokuGrid();

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(0, d)) grid.removeCandidate(0, d);
        }
        grid
          ..addCandidate(0, 1)
          ..addCandidate(0, 2)
          ..addCandidate(0, 4);

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(1, d)) grid.removeCandidate(1, d);
        }
        grid
          ..addCandidate(1, 2)
          ..addCandidate(1, 3)
          ..addCandidate(1, 5);

        for (var d = 1; d <= 9; d++) {
          if (grid.isCandidate(2, d)) grid.removeCandidate(2, d);
        }
        grid
          ..addCandidate(2, 1)
          ..addCandidate(2, 3)
          ..addCandidate(2, 6);

        for (var i = 3; i < 9; i++) {
          if (grid.isCandidate(i, 1)) grid.removeCandidate(i, 1);
          if (grid.isCandidate(i, 2)) grid.removeCandidate(i, 2);
          if (grid.isCandidate(i, 3)) grid.removeCandidate(i, 3);
        }

        final hiddenTriple = HiddenTriple();
        final hints = hiddenTriple.getHints(grid);

        expect(hints, isNotEmpty);
        expect(hints.first.isPlacement(), isFalse);
      });
    });
  });
}
