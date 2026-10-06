import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/game_engine.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';

import '../../helpers/sudoku_grids.dart';

GameEngine _makeEngine() {
  final state = GameState.newGame(
    puzzle: Puzzle(
      given: TestGrids.simplePuzzle(),
      solution: TestGrids.simpleSolution(),
    ),
    difficulty: .easy,
  );
  return GameEngine(state);
}

void main() {
  group('DigitAction.undo', () {
    test('restores grid value and previous notes', () {
      final engine = _makeEngine()
        ..toggleNote(2, 3)
        ..toggleNote(2, 5)
        ..inputDigit(2, 4);

      final action = engine.currentState.history.last as DigitAction;
      final newState = action.undo(engine.currentState);

      expect(newState.grid.valueAt(2), 0);
      expect(newState.notes[2], containsAll([3, 5]));
    });

    test('trims history from state', () {
      final engine = _makeEngine()..inputDigit(2, 4);
      final action = engine.currentState.history.last as DigitAction;
      final newState = action.undo(engine.currentState);

      expect(newState.history, isEmpty);
    });
  });

  group('PencilAction.undo', () {
    test('restores previous state', () {
      final engine = _makeEngine()..toggleNote(2, 4);

      final action = engine.currentState.history.last as PencilAction;
      final newState = action.undo(engine.currentState);

      expect(newState.notes[2], isEmpty);
    });

    test('trims history from state', () {
      final engine = _makeEngine()..toggleNote(2, 4);
      final action = engine.currentState.history.last as PencilAction;
      final newState = action.undo(engine.currentState);

      expect(newState.history, isEmpty);
    });
  });

  group('EraseAction.undo', () {
    test('restores grid value and notes', () {
      final engine = _makeEngine()
        ..inputDigit(2, 4)
        ..erase(2);

      final action = engine.currentState.history.last as EraseAction;
      final newState = action.undo(engine.currentState);

      expect(newState.grid.valueAt(2), 4);
    });

    test('restores grid notes', () {
      final engine = _makeEngine()
        ..toggleNote(2, 3)
        ..toggleNote(2, 5)
        ..erase(2);

      final action = engine.currentState.history.last as EraseAction;
      final newState = action.undo(engine.currentState);

      expect(newState.notes[2], containsAll([3, 5]));
    });

    test('trims history from state', () {
      final engine = _makeEngine()
        ..inputDigit(2, 4)
        ..erase(2);
      final action = engine.currentState.history.last as EraseAction;
      final newState = action.undo(engine.currentState);

      expect(newState.history.length, 1);
    });
  });

  group('AutoNotesAction.undo', () {
    test('restores previous notes', () {
      final engine = _makeEngine()..autoFillNotes();

      final action = engine.currentState.history.last as AutoNotesAction;
      final newState = action.undo(engine.currentState);

      expect(newState.notes.every((s) => s.isEmpty), isTrue);
    });

    test('trims history from state', () {
      final engine = _makeEngine()..autoFillNotes();
      final action = engine.currentState.history.last as AutoNotesAction;
      final newState = action.undo(engine.currentState);

      expect(newState.history, isEmpty);
    });
  });
}
