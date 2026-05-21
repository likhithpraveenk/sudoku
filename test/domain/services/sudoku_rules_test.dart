import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

import '../../helpers/sudoku_grids.dart';

void main() {
  group('SudokuRules', () {
    test('peers returns correct cells', () {
      final grid = TestGrids.empty();
      const cell = 0;
      final peersResult = peers(grid, cell);

      expect(peersResult.length, 20);

      expect(peersResult.contains(cell), isFalse);

      for (var col = 1; col < 9; col++) {
        expect(peersResult.contains(col), isTrue);
      }

      for (var row = 1; row < 9; row++) {
        expect(peersResult.contains(row * 9), isTrue);
      }

      for (var row = 0; row < 3; row++) {
        for (var col = 1; col < 3; col++) {
          expect(peersResult.contains(row * 9 + col), isTrue);
        }
      }
    });

    test('isConflict detects conflicts correctly', () {
      final grid = TestGrids.empty();

      expect(isConflict(grid, 1, 5), isFalse);

      final gridWithConflict = TestGrids.gridWithRowConflict();

      expect(isConflict(gridWithConflict, 1, 5), isTrue);

      expect(isConflict(gridWithConflict, 9, 5), isTrue);

      expect(isConflict(gridWithConflict, 10, 5), isTrue);

      expect(isConflict(gridWithConflict, 1, 3), isFalse);
    });

    test('isSolved works correctly', () {
      final solutionGrid = TestGrids.simpleSolution();

      expect(isSolved(solutionGrid, solutionGrid), isTrue);

      final differentGrid = TestGrids.simplePuzzle();

      expect(isSolved(differentGrid, solutionGrid), isFalse);
    });

    test('applyDigit works correctly', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final newState = applyDigit(initialState, cell, 4);

      expect(newState.grid.valueAt(cell), 4);

      expect(newState.notes[0].contains(4), isFalse);

      expect(newState.notes[20].contains(4), isFalse);

      expect(newState.notes[10].contains(4), isFalse);

      expect(newState.notes[cell].isEmpty, isTrue);

      final incorrectState = applyDigit(newState, 3, 9);

      expect(incorrectState.grid.valueAt(3), 9);

      expect(incorrectState.notes[3].isEmpty, isTrue);

      final correctedState = applyDigit(incorrectState, 3, 6);

      expect(correctedState.grid.valueAt(3), 6);

      expect(correctedState.notes[3].isEmpty, isTrue);
    });
  });
}
