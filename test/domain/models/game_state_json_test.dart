import 'dart:convert';

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

/// What the save service does around a game.
GameState _roundTrip(GameState state) {
  final json = jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>;
  return GameState.fromJson(json);
}

/// A game with one action of every kind in its history.
GameEngine _engineWithEveryAction() => _makeEngine()
  ..toggleNote(2, 3)
  ..inputDigit(3, 4)
  ..erase(3)
  ..autoFillNotes();

void main() {
  group('saved history', () {
    test('keeps every action type across a save', () {
      final engine = _engineWithEveryAction();
      final restored = _roundTrip(engine.currentState);

      expect(restored.history, hasLength(engine.currentState.history.length));
      expect(restored.grid.values, engine.currentState.grid.values);
      expect(restored.notes, engine.currentState.notes);
    });

    test('undo still works after a reload', () {
      final engine = _engineWithEveryAction();
      final restored = GameEngine(_roundTrip(engine.currentState));

      final live = GameEngine(engine.currentState);
      for (var i = 0; i < 4; i++) {
        live.undo();
        restored.undo();
        expect(
          restored.currentState.grid.values,
          live.currentState.grid.values,
        );
        expect(restored.currentState.notes, live.currentState.notes);
      }

      expect(restored.canUndo, isFalse);
    });

    test('a save written before history was stored loads with none', () {
      final state = _engineWithEveryAction().currentState;
      final json = state.toJson()..remove('history');

      final restored = GameState.fromJson(json);

      expect(restored.history, isEmpty);
      expect(restored.grid.values, state.grid.values);
    });

    test('a history that cannot be read is dropped, not the board', () {
      final state = _engineWithEveryAction().currentState;
      final json = state.toJson()
        ..['history'] = [
          {'type': 'digit', 'cell': 3},
        ];

      final restored = GameState.fromJson(json);

      expect(restored.history, isEmpty);
      expect(restored.grid.values, state.grid.values);
    });

    test('every action type encodes under its own name', () {
      final actions = _engineWithEveryAction().currentState.history;

      expect(actions.map((a) => a.toJson()['type']), [
        'pencil',
        'digit',
        'erase',
        'autoNotes',
      ]);
      for (final action in actions) {
        final restored = GameAction.fromJson(action.toJson());
        expect(restored.runtimeType, action.runtimeType);
      }
    });
  });
}
