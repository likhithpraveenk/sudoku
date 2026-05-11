import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

import '../../helpers/sudoku_boards.dart';

void main() {
  group('SudokuRules', () {
    late SudokuRules rules;

    setUp(() {
      rules = const SudokuRules();
    });

    test('peers returns correct cells', () {
      final board = TestBoards.empty();
      const cell = Cell(0, 0);
      final peers = rules.peers(board, cell);

      expect(peers.length, 20);

      expect(peers.contains(cell), isFalse);

      for (int col = 1; col < 9; col++) {
        expect(peers.contains(Cell(0, col)), isTrue);
      }

      for (int row = 1; row < 9; row++) {
        expect(peers.contains(Cell(row, 0)), isTrue);
      }

      for (int row = 0; row < 3; row++) {
        for (int col = 1; col < 3; col++) {
          expect(peers.contains(Cell(row, col)), isTrue);
        }
      }
    });

    test('isConflict detects conflicts correctly', () {
      final board = TestBoards.empty();

      expect(rules.isConflict(board, const Cell(0, 1), 5), isFalse);

      final boardWithConflict = TestBoards.boardWithRowConflict();

      expect(rules.isConflict(boardWithConflict, const Cell(0, 1), 5), isTrue);

      expect(rules.isConflict(boardWithConflict, const Cell(1, 0), 5), isTrue);

      expect(rules.isConflict(boardWithConflict, const Cell(1, 1), 5), isTrue);

      expect(rules.isConflict(boardWithConflict, const Cell(0, 1), 3), isFalse);
    });

    test('isSolved works correctly', () {
      final solutionBoard = TestBoards.simpleSolution();

      expect(rules.isSolved(solutionBoard, solutionBoard), isTrue);

      final differentBoard = TestBoards.simplePuzzle();

      expect(rules.isSolved(differentBoard, solutionBoard), isFalse);
    });

    test('applyDigit works correctly', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = Cell(0, 2);
      final newState = rules.applyDigit(initialState, cell, 4);

      expect(newState.board[cell], 4);

      expect(newState.notes[const Cell(0, 0).index].contains(4), isFalse);

      expect(newState.notes[const Cell(2, 2).index].contains(4), isFalse);

      expect(newState.notes[const Cell(1, 1).index].contains(4), isFalse);

      expect(newState.notes[cell.index].isEmpty, isTrue);

      final incorrectState = rules.applyDigit(newState, const Cell(0, 3), 9);

      expect(incorrectState.errorCells.contains(const Cell(0, 3)), isTrue);

      expect(incorrectState.mistakeCount, 1);

      final correctedState = rules.applyDigit(
        incorrectState,
        const Cell(0, 3),
        6,
      );

      expect(correctedState.errorCells.contains(const Cell(0, 3)), isFalse);

      expect(correctedState.mistakeCount, 1);
    });
  });
}
