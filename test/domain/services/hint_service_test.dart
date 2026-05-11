import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/hint_service.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

import '../../helpers/sudoku_boards.dart';

void main() {
  group('HintService', () {
    late HintService hintService;

    setUp(() {
      hintService = const HintService(SudokuRules());
    });

    test('revealCell reveals correct digit', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = Cell(0, 2);
      final stateAfterReveal = hintService.revealCell(initialState, cell);

      expect(stateAfterReveal.board[cell], 4);

      expect(stateAfterReveal.revealedCells.contains(cell), isTrue);

      expect(stateAfterReveal.notes[cell.index].isEmpty, isTrue);

      final stateWithError = initialState.copyWith(
        board: initialState.board.setCell(cell, 9),
        errorCells: {cell},
      );
      final stateAfterRevealWithError = hintService.revealCell(
        stateWithError,
        cell,
      );

      expect(stateAfterRevealWithError.errorCells.contains(cell), isFalse);
    });

    test('revealCell does nothing for given cells', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const givenCell = Cell(0, 0);
      final stateAfterReveal = hintService.revealCell(initialState, givenCell);

      expect(stateAfterReveal, equals(initialState));
    });

    test('validate flags incorrect cells', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = Cell(0, 2);
      final stateWithError = initialState.copyWith(
        board: initialState.board.setCell(cell, 9),
      );
      final validatedState = hintService.validate(stateWithError);

      expect(validatedState.errorCells.contains(cell), isTrue);

      const correctCell = Cell(0, 1);
      expect(validatedState.errorCells.contains(correctCell), isFalse);
    });

    test('validationResult returns correct status', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );

      final correctState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      expect(
        hintService.validationResult(correctState),
        ValidationResult.correct,
      );

      final stateWithError = correctState.copyWith(
        board: correctState.board.setCell(const Cell(0, 2), 9),
      );
      expect(
        hintService.validationResult(stateWithError),
        ValidationResult.hasErrors,
      );

      final solvedState = correctState.copyWith(
        board: solutionBoard,
        isSolved: true,
      );
      expect(
        hintService.validationResult(solvedState),
        ValidationResult.complete,
      );
    });
  });
}
