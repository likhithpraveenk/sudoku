import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/note_service.dart';

import '../../helpers/sudoku_grids.dart';

void main() {
  group('NoteService', () {
    test('toggle adds and removes notes correctly', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      const cell = 2;

      final stateWithNote = toggleNote(initialState, cell, 4);

      expect(stateWithNote.notes[cell].contains(4), isTrue);

      expect(stateWithNote.history.length, 1);

      expect(stateWithNote.history.first, isA<PencilAction>());

      final stateWithoutNote = toggleNote(stateWithNote, cell, 4);

      expect(stateWithoutNote.notes[cell].contains(4), isFalse);

      expect(stateWithoutNote.history.length, 2);
    });

    test('toggle does nothing for given cells', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      const givenCell = 0;
      final stateAfterToggle = toggleNote(initialState, givenCell, 4);

      expect(stateAfterToggle, equals(initialState));
    });

    test('autoFill computes correct pencil marks', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);
      final stateAfterAutoFill = autoFillNotes(initialState);

      for (var i = 0; i < 81; i++) {
        if (puzzleGrid.valueAt(i) != 0) {
          expect(
            stateAfterAutoFill.notes[i].isEmpty,
            isTrue,
            reason: 'Given cell at index $i should have no notes',
          );
        }
      }

      const cell = 2;
      expect(stateAfterAutoFill.notes[cell], equals({1, 2, 4}));
    });

    test('clearCell clears notes for a cell', () {
      final puzzleGrid = TestGrids.simplePuzzle();
      final solutionGrid = TestGrids.simpleSolution();

      final puzzle = Puzzle(given: puzzleGrid, solution: solutionGrid);
      final initialState = GameState.newGame(puzzle: puzzle, difficulty: .easy);

      const cell = 2;
      final stateWithNotes = toggleNote(initialState, cell, 4);
      final stateWithMoreNotes = toggleNote(stateWithNotes, cell, 7);

      expect(stateWithMoreNotes.notes[cell].contains(4), isTrue);
      expect(stateWithMoreNotes.notes[cell].contains(7), isTrue);

      final stateAfterClear = clearCellNotes(stateWithMoreNotes, cell);

      expect(stateAfterClear.notes[cell].isEmpty, isTrue);
    });
  });
}
