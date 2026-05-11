import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/note_service.dart';

import '../../helpers/sudoku_boards.dart';

void main() {
  group('NoteService', () {
    late NoteService noteService;

    setUp(() {
      noteService = const NoteService();
    });

    test('toggle adds and removes notes correctly', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      const cell = Cell(0, 2);

      final stateWithNote = noteService.toggle(initialState, cell, 4);

      expect(stateWithNote.notes[cell.index].contains(4), isTrue);

      expect(stateWithNote.history.length, 1);

      expect(stateWithNote.history.first, isA<PencilAction>());

      final stateWithoutNote = noteService.toggle(stateWithNote, cell, 4);

      expect(stateWithoutNote.notes[cell.index].contains(4), isFalse);

      expect(stateWithoutNote.history.length, 2);
    });

    test('toggle does nothing for given cells', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      const givenCell = Cell(0, 0);
      final stateAfterToggle = noteService.toggle(initialState, givenCell, 4);

      expect(stateAfterToggle, equals(initialState));
    });

    test('toggle does nothing for revealed cells', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();
      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );

      const revealedCell = Cell(0, 2);
      final baseState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      final stateWithReveal = baseState.copyWith(revealedCells: {revealedCell});

      final stateAfterToggle = noteService.toggle(
        stateWithReveal,
        revealedCell,
        4,
      );
      expect(stateAfterToggle, equals(stateWithReveal));
    });

    test('autoFill computes correct pencil marks', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      final stateAfterAutoFill = noteService.autoFill(initialState);

      for (int i = 0; i < 81; i++) {
        if (puzzleBoard.atIndex(i) != 0) {
          expect(
            stateAfterAutoFill.notes[i].isEmpty,
            isTrue,
            reason: 'Given cell at index $i should have no notes',
          );
        }
      }

      const cell = Cell(0, 2);
      expect(stateAfterAutoFill.notes[cell.index], equals({1, 2, 4}));
    });

    test('clearCell clears notes for a cell', () {
      final puzzleBoard = TestBoards.simplePuzzle();
      final solutionBoard = TestBoards.simpleSolution();

      final puzzle = Puzzle(
        board: puzzleBoard,
        solution: solutionBoard,
        givenMask: List.generate(81, (i) => puzzleBoard.atIndex(i) != 0),
      );
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = Cell(0, 2);
      final stateWithNotes = noteService.toggle(initialState, cell, 4);
      final stateWithMoreNotes = noteService.toggle(stateWithNotes, cell, 7);

      expect(stateWithMoreNotes.notes[cell.index].contains(4), isTrue);
      expect(stateWithMoreNotes.notes[cell.index].contains(7), isTrue);

      final stateAfterClear = noteService.clearCell(stateWithMoreNotes, cell);

      expect(stateAfterClear.notes[cell.index].isEmpty, isTrue);
    });
  });
}
