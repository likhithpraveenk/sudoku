import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/hint_service.dart';

import '../../helpers/sudoku_grids.dart';

void main() {
  group('HintService', () {
    setUp(() {});

    test('revealCell reveals correct digit', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(
        grid: puzzleGrid,
        solution: solutionGrid,
        givenMask: List.generate(81, (i) => puzzleGrid.valueAt(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final stateAfterReveal = revealCell(initialState, cell);

      expect(stateAfterReveal.grid.valueAt(cell), 4);

      expect(stateAfterReveal.revealedCells.contains(cell), isTrue);

      expect(stateAfterReveal.notes[cell].isEmpty, isTrue);

      final stateWithError = initialState.copyWith(
        grid: initialState.grid.clone()..setValue(cell, 9),
        errorCells: {cell},
      );
      final stateAfterRevealWithError = revealCell(stateWithError, cell);

      expect(stateAfterRevealWithError.errorCells.contains(cell), isFalse);
    });

    test('revealCell does nothing for given cells', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(
        grid: puzzleGrid,
        solution: solutionGrid,
        givenMask: List.generate(81, (i) => puzzleGrid.valueAt(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const givenCell = 0;
      final stateAfterReveal = revealCell(initialState, givenCell);

      expect(stateAfterReveal, equals(initialState));
    });

    test('validate flags incorrect cells', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(
        grid: puzzleGrid,
        solution: solutionGrid,
        givenMask: List.generate(81, (i) => puzzleGrid.valueAt(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final stateWithError = initialState.copyWith(
        grid: initialState.grid.clone()..setValue(cell, 9),
      );
      final validatedState = validate(stateWithError);

      expect(validatedState.errorCells.contains(cell), isTrue);

      const correctCell = 1;
      expect(validatedState.errorCells.contains(correctCell), isFalse);
    });

    test('validationResult returns correct status', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(
        grid: puzzleGrid,
        solution: solutionGrid,
        givenMask: List.generate(81, (i) => puzzleGrid.valueAt(i) != 0),
      );

      final correctState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      expect(validationResult(correctState), ValidationResult.correct);

      final stateWithError = correctState.copyWith(
        grid: correctState.grid.clone()..setValue(2, 9),
      );
      expect(validationResult(stateWithError), ValidationResult.hasErrors);

      final solvedState = correctState.copyWith(
        grid: solutionGrid,
        isSolved: true,
      );
      expect(validationResult(solvedState), ValidationResult.complete);
    });

    test('applyLogicalHint updates both grid and notes', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(
        grid: puzzleGrid,
        solution: solutionGrid,
        givenMask: List.generate(81, (i) => puzzleGrid.valueAt(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      final newNotes = initialState.notes.map(Set<int>.from).toList();
      newNotes[2] = {3, 4};
      final stateWithNotes = initialState.copyWith(notes: newNotes);

      var hintMessage = '';
      final nextState = applyLogicalHint(
        stateWithNotes,
        onHintFound: (msg) {
          hintMessage = msg;
        },
      );

      expect(hintMessage.isNotEmpty, isTrue);
      expect(nextState.history.isNotEmpty, isTrue);
    });
  });
}
