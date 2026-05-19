import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/services/undo_service.dart';

import '../../helpers/sudoku_grids.dart';

void main() {
  group('UndoService', () {
    test('canUndo returns false for empty history', () {
      final state = GameState.newGame(
        puzzle: Puzzle(
          grid: TestGrids.empty(),
          solution: TestGrids.empty(),
          givenMask: List.generate(81, (_) => false),
        ),
        difficulty: .easy,
      );
      expect(canUndo(state), isFalse);
    });

    test('canUndo returns true for non-empty history', () {
      final state =
          GameState.newGame(
            puzzle: Puzzle(
              grid: TestGrids.empty(),
              solution: TestGrids.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            history: [
              const DigitAction(
                cellIndex: 0,
                previousValue: 0,
                newValue: 1,
                previousNotes: {},
              ),
            ],
          );
      expect(canUndo(state), isTrue);
    });

    test('pop does nothing when history is empty', () {
      final state = GameState.newGame(
        puzzle: Puzzle(
          grid: TestGrids.empty(),
          solution: TestGrids.empty(),
          givenMask: List.generate(81, (_) => false),
        ),
        difficulty: .easy,
      );
      final result = popUndo(state);
      expect(result, equals(state));
    });

    test('pop undoes a DigitAction', () {
      const cell = 0;
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              grid: TestGrids.empty(),
              solution: TestGrids.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            grid: TestGrids.empty().clone()..setValue(cell, 1),
            history: [
              const DigitAction(
                cellIndex: cell,
                previousValue: 0,
                newValue: 1,
                previousNotes: {},
              ),
            ],
          );

      final result = popUndo(initialState);
      expect(result.grid.valueAt(cell), 0);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes a PencilAction', () {
      const cell = 0;
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              grid: TestGrids.empty(),
              solution: TestGrids.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            notes: List.generate(81, (_) => <int>{})..[cell] = {1},
            history: [
              const PencilAction(
                cellIndex: cell,
                previousNotes: {},
                newNotes: {1},
              ),
            ],
          );

      final result = popUndo(initialState);

      expect(result.notes[cell].isEmpty, isTrue);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes an EraseAction', () {
      const cell = 0;
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              grid: TestGrids.empty(),
              solution: TestGrids.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            grid: TestGrids.empty().clone()..setValue(cell, 1),
            notes: List.generate(81, (_) => <int>{})..[cell] = {1},
            history: [
              const EraseAction(
                cellIndex: cell,
                previousValue: 1,
                previousNotes: {1},
              ),
            ],
          );
      final result = popUndo(initialState);

      expect(result.grid.valueAt(cell), 1);
      expect(result.notes[cell].contains(1), isTrue);
      expect(result.history.isEmpty, isTrue);
    });

    test('pop undoes an AutoNotesAction', () {
      const cell = 0;
      final previousNotes = List.generate(81, (_) => <int>{})
        ..[cell] = {1, 2, 3};
      final initialState =
          GameState.newGame(
            puzzle: Puzzle(
              grid: TestGrids.empty(),
              solution: TestGrids.empty(),
              givenMask: List.generate(81, (_) => false),
            ),
            difficulty: .easy,
          ).copyWith(
            notes: List.generate(81, (_) => <int>{}),
            history: [AutoNotesAction(previousNotes: previousNotes)],
          );
      final result = popUndo(initialState);

      expect(result.notes[cell], equals({1, 2, 3}));
      expect(result.history.isEmpty, isTrue);
    });
  });
}
