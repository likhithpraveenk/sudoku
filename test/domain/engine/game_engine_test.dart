import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/engine/game_engine.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/providers/game_notifier.dart';

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
  group('GameEngine', () {
    group('tick', () {
      test('increments elapsed by one second', () {
        final engine = _makeEngine();
        expect(engine.currentState.elapsed, Duration.zero);

        engine.tick(kTick);

        expect(engine.currentState.elapsed, kTick);
      });

      test('accumulates across multiple ticks', () {
        final engine = _makeEngine();

        engine
          ..tick(kTick)
          ..tick(kTick)
          ..tick(kTick);

        expect(engine.currentState.elapsed, kTick * 3);
      });
    });

    group('inputDigit', () {
      test('places digit on empty cell', () {
        final engine = _makeEngine();

        engine.inputDigit(2, 4);

        expect(engine.currentState.grid.valueAt(2), 4);
      });

      test('records DigitAction in history', () {
        final engine = _makeEngine();

        engine.inputDigit(2, 4);

        expect(engine.currentState.history.last, isA<DigitAction>());
      });

      test('ignores given cells', () {
        final engine = _makeEngine();

        engine.inputDigit(0, 9);

        expect(engine.currentState.grid.valueAt(0), 5);
        expect(engine.currentState.history, isEmpty);
      });

      test('same digit on filled cell erases it', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..inputDigit(2, 4);

        expect(engine.currentState.grid.valueAt(2), 0);
      });

      test('clears own cell notes on placement', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 3)
          ..toggleNote(2, 5)
          ..inputDigit(2, 4);

        expect(engine.currentState.notes[2], isEmpty);
      });

      test('does not remove peer notes when autoRemoveNotes is false', () {
        final engine = _makeEngine();

        engine.toggleNote(5, 4);
        engine.inputDigit(2, 4, autoRemoveNotes: false);

        expect(engine.currentState.notes[5], contains(4));
      });

      test('removes digit from peer notes when autoRemoveNotes is true', () {
        final engine = _makeEngine();

        engine.toggleNote(5, 4);

        engine.inputDigit(2, 4, autoRemoveNotes: true);

        expect(engine.currentState.notes[5], isNot(contains(4)));
      });

      test('marks puzzle complete when last cell is correctly filled', () {
        final engine = _makeEngine();

        var state = engine.currentState;
        final solution = state.puzzle.solution;

        for (var i = 0; i < 81; i++) {
          if (!state.puzzle.isGivenAt(i)) {
            engine.inputDigit(i, solution.valueAt(i));
            state = engine.currentState;
            if (state.puzzleComplete) break;
          }
        }

        expect(engine.currentState.puzzleComplete, isTrue);
      });

      test('does not mark complete on wrong digit', () {
        final engine = _makeEngine();
        final solution = engine.currentState.puzzle.solution;

        for (var i = 0; i < 81; i++) {
          if (!engine.currentState.puzzle.isGivenAt(i)) {
            final correct = solution.valueAt(i);
            final wrong = correct == 9 ? 1 : correct + 1;
            engine.inputDigit(i, i == 2 ? wrong : correct);
          }
        }

        expect(engine.currentState.puzzleComplete, isFalse);
      });
    });

    group('toggleNote', () {
      test('adds digit to notes', () {
        final engine = _makeEngine();

        engine.toggleNote(2, 4);

        expect(engine.currentState.notes[2], contains(4));
      });

      test('removes digit if already present', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 4)
          ..toggleNote(2, 4);

        expect(engine.currentState.notes[2], isNot(contains(4)));
      });

      test('can hold multiple digits', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 3)
          ..toggleNote(2, 5)
          ..toggleNote(2, 7);

        expect(engine.currentState.notes[2], containsAll([3, 5, 7]));
      });

      test('records PencilAction in history', () {
        final engine = _makeEngine();

        engine.toggleNote(2, 4);

        expect(engine.currentState.history.last, isA<PencilAction>());
      });

      test('ignores given cells', () {
        final engine = _makeEngine();

        engine.toggleNote(0, 4);

        expect(engine.currentState.notes[0], isEmpty);
        expect(engine.currentState.history, isEmpty);
      });

      test('does not write a grid value', () {
        final engine = _makeEngine();

        engine.toggleNote(2, 4);

        expect(engine.currentState.grid.valueAt(2), 0);
      });
    });

    group('erase', () {
      test('clears a placed digit', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..erase(2);

        expect(engine.currentState.grid.valueAt(2), 0);
      });

      test('clears notes', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 3)
          ..toggleNote(2, 5)
          ..erase(2);

        expect(engine.currentState.notes[2], isEmpty);
      });

      test('records EraseAction in history', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..erase(2);

        expect(engine.currentState.history.last, isA<EraseAction>());
      });

      test('is a no-op on already empty cell with no notes', () {
        final engine = _makeEngine();

        engine.erase(2);

        expect(engine.currentState.history, isEmpty);
      });

      test('ignores given cells', () {
        final engine = _makeEngine();

        engine.erase(0);

        expect(engine.currentState.grid.valueAt(0), 5);
        expect(engine.currentState.history, isEmpty);
      });
    });

    group('undo', () {
      test('is a no-op when history is empty', () {
        final engine = _makeEngine();

        engine.undo();

        expect(engine.currentState.history, isEmpty);
      });

      test('canUndo is false initially', () {
        expect(_makeEngine().canUndo, isFalse);
      });

      test('canUndo is true after an action', () {
        final engine = _makeEngine();

        engine.inputDigit(2, 4);

        expect(engine.canUndo, isTrue);
      });

      test('canUndo is false after undoing the only action', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..undo();

        expect(engine.canUndo, isFalse);
      });

      test('reverts DigitAction — restores grid value', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..undo();

        expect(engine.currentState.grid.valueAt(2), 0);
      });

      test('reverts DigitAction — removes from history', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..undo();

        expect(engine.currentState.history, isEmpty);
      });

      test('reverts DigitAction — restores cleared cell notes', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 3)
          ..toggleNote(2, 5);

        engine
          ..inputDigit(2, 4)
          ..undo();

        expect(engine.currentState.notes[2], containsAll([3, 5]));
      });

      test(
        'reverts DigitAction — restores peer notes removed by autoRemoveNotes',
        () {
          final engine = _makeEngine();

          engine.toggleNote(5, 4);

          engine.inputDigit(2, 4, autoRemoveNotes: true);
          expect(engine.currentState.notes[5], isNot(contains(4)));

          engine.undo();
          expect(engine.currentState.notes[5], contains(4));
        },
      );

      test('reverts PencilAction — removes added note', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 4)
          ..undo();

        expect(engine.currentState.notes[2], isNot(contains(4)));
      });

      test('reverts PencilAction — restores removed note', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 4)
          ..toggleNote(2, 4)
          ..undo();

        expect(engine.currentState.notes[2], contains(4));
      });

      test('reverts EraseAction — restores grid value', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..erase(2)
          ..undo();

        expect(engine.currentState.grid.valueAt(2), 4);
      });

      test('reverts EraseAction — restores notes', () {
        final engine = _makeEngine();

        engine
          ..toggleNote(2, 3)
          ..toggleNote(2, 5)
          ..erase(2)
          ..undo();

        expect(engine.currentState.notes[2], containsAll([3, 5]));
      });

      test('reverts AutoNotesAction', () {
        final engine = _makeEngine();

        engine.autoFillNotes();
        expect(engine.currentState.notes.any((s) => s.isNotEmpty), isTrue);

        engine.undo();
        expect(engine.currentState.notes.every((s) => s.isEmpty), isTrue);
      });

      test('multiple undo walk back multiple actions', () {
        final engine = _makeEngine();

        engine
          ..inputDigit(2, 4)
          ..inputDigit(3, 6)
          ..undo()
          ..undo();

        expect(engine.currentState.grid.valueAt(2), 0);
        expect(engine.currentState.grid.valueAt(3), 0);
        expect(engine.currentState.history, isEmpty);
      });
    });

    group('revealHint', () {
      test('fills an empty or wrong cell', () {
        final engine = _makeEngine();
        final before = List<int>.from(engine.currentState.grid.values);

        engine.revealHint();

        expect(engine.currentState.grid.values, isNot(equals(before)));
      });

      test('sets assists.hints to true', () {
        final engine = _makeEngine();

        engine.revealHint();

        expect(engine.currentState.assists.hints, isTrue);
      });

      test('placed value matches solution', () {
        final engine = _makeEngine();
        final solution = engine.currentState.puzzle.solution;

        engine.revealHint();

        for (var i = 0; i < 81; i++) {
          final v = engine.currentState.grid.valueAt(i);
          if (v != 0) {
            expect(
              v,
              solution.valueAt(i),
              reason: 'Cell $i has wrong value after hint',
            );
          }
        }
      });

      test('is a no-op on completed puzzle', () {
        final engine = _makeEngine();
        final solution = engine.currentState.puzzle.solution;

        for (var i = 0; i < 81; i++) {
          if (!engine.currentState.puzzle.isGivenAt(i)) {
            engine.inputDigit(i, solution.valueAt(i));
          }
        }

        final valuesAfterSolve = List<int>.from(
          engine.currentState.grid.values,
        );
        engine.revealHint();

        expect(engine.currentState.grid.values, equals(valuesAfterSolve));
      });
    });

    group('findErrors', () {
      test('returns empty set for correct grid', () {
        final engine = _makeEngine();

        expect(engine.findErrors(), isEmpty);
      });

      test('returns indices of wrong cells', () {
        final engine = _makeEngine();
        final solution = engine.currentState.puzzle.solution;
        final correct = solution.valueAt(2);
        final wrong = correct == 9 ? 1 : correct + 1;

        engine.inputDigit(2, wrong);

        expect(engine.findErrors(), contains(2));
      });

      test('does not include empty cells', () {
        final engine = _makeEngine();

        expect(engine.findErrors(), isNot(contains(2)));
      });

      test('sets assists.validation to true', () {
        final engine = _makeEngine();

        engine.findErrors();

        expect(engine.currentState.assists.validation, isTrue);
      });

      test('stays true after being set', () {
        final engine = _makeEngine();

        engine.findErrors();
        engine.findErrors();

        expect(engine.currentState.assists.validation, isTrue);
      });
    });

    group('autoFillNotes', () {
      test('fills notes on empty non-given cells', () {
        final engine = _makeEngine();

        engine.autoFillNotes();

        expect(engine.currentState.notes.any((s) => s.isNotEmpty), isTrue);
      });

      test('only includes valid candidates', () {
        final engine = _makeEngine();

        engine.autoFillNotes();

        final state = engine.currentState;
        for (var i = 0; i < 81; i++) {
          if (state.grid.valueAt(i) != 0 || state.puzzle.isGivenAt(i)) continue;
          final candidates = state.grid.getCandidates(i);
          for (final note in state.notes[i]) {
            expect(
              candidates,
              contains(note),
              reason: 'Cell $i has note $note which is not a valid candidate',
            );
          }
        }
      });

      test('skips given cells', () {
        final engine = _makeEngine();

        engine.autoFillNotes();

        expect(engine.currentState.notes[0], isEmpty);
      });

      test('skips filled cells', () {
        final engine = _makeEngine();

        engine.inputDigit(2, 4);
        engine.autoFillNotes();

        expect(engine.currentState.notes[2], isEmpty);
      });

      test('records AutoNotesAction in history', () {
        final engine = _makeEngine();

        engine.autoFillNotes();

        expect(engine.currentState.history.last, isA<AutoNotesAction>());
      });

      test('sets assists.autoNotes to true', () {
        final engine = _makeEngine();

        engine.autoFillNotes();

        expect(engine.currentState.assists.autoNotes, isTrue);
      });
    });
  });
}
