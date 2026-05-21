import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/hint_service.dart';

import '../../helpers/sudoku_grids.dart';

void main() {
  group('HintService', () {
    setUp(() {});

    test('revealCell reveals a digit', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final stateAfterReveal = revealCell(initialState);

      expect(stateAfterReveal.grid.valueAt(cell), 4);

      expect(stateAfterReveal.notes[cell].isEmpty, isTrue);
    });

    test('validate flags incorrect cells', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final stateWithError = initialState.copyWith(
        grid: initialState.grid.clone()..setValue(cell, 9),
      );
      final errorCells = findErrors(stateWithError);

      expect(errorCells.contains(cell), isTrue);

      const correctCell = 1;
      expect(errorCells.contains(correctCell), isFalse);
    });
  });
}
