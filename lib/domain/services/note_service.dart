import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

/// The [toggleNote] method.
GameState toggleNote(GameState state, int index, int digit) {
  if (state.puzzle.isGivenAt(index)) return state;
  if (state.revealedCells.contains(index)) return state;
  if (state.grid.valueAt(index) != 0) return state;

  final current = Set<int>.from(state.notes[index]);
  final updated = current.contains(digit)
      ? (current..remove(digit))
      : (current..add(digit));

  final action = PencilAction(
    cellIndex: index,
    previousNotes: Set.from(state.notes[index]),
    newNotes: Set.from(updated),
  );

  final newNotes = state.notes.map(Set<int>.from).toList();
  newNotes[index] = updated;

  return state.copyWith(notes: newNotes, history: [...state.history, action]);
}

/// The [autoFillNotes] method.
GameState autoFillNotes(GameState state) {
  final prevNotes = state.notes.map(Set<int>.from).toList();

  final newNotes = List<Set<int>>.generate(81, (i) {
    if (state.grid.valueAt(i) != 0 || state.puzzle.isGivenAt(i)) {
      return <int>{};
    }

    final used = <int>{};
    for (final peer in peersOf(i)) {
      final v = state.grid.valueAt(peer);
      if (v != 0) used.add(v);
    }

    return {1, 2, 3, 4, 5, 6, 7, 8, 9}..removeAll(used);
  });

  return state.copyWith(
    notes: newNotes,
    history: [
      ...state.history,
      AutoNotesAction(previousNotes: prevNotes),
    ],
  );
}

/// The [clearCellNotes] method.
GameState clearCellNotes(GameState state, int index) {
  final newNotes = state.notes.map(Set<int>.from).toList();
  newNotes[index] = {};
  return state.copyWith(notes: newNotes);
}
