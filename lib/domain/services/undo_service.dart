import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

/// The [canUndo] method.
bool canUndo(GameState state) => state.history.isNotEmpty;

/// The [popUndo] method.
GameState popUndo(GameState state) {
  if (!canUndo(state)) return state;

  final action = state.history.last;
  final remaining = state.history.sublist(0, state.history.length - 1);

  return switch (action) {
    DigitAction() => () {
      final newNotes = state.notes.map(Set<int>.from).toList();
      action.previousNotes.forEach((i, notes) {
        newNotes[i] = Set.from(notes);
      });
      final grid = state.grid.clone()
        ..setValue(action.cellIndex, action.previousValue);
      return state.copyWith(
        grid: grid,
        notes: newNotes,
        history: remaining,
        errorCells: Set.from(state.errorCells)..remove(action.cellIndex),
      );
    }(),
    PencilAction() => () {
      final newNotes = state.notes.map(Set<int>.from).toList();
      newNotes[action.cellIndex] = Set.from(action.previousNotes);
      return state.copyWith(notes: newNotes, history: remaining);
    }(),
    EraseAction() => () {
      final newNotes = state.notes.map(Set<int>.from).toList();
      newNotes[action.cellIndex] = Set.from(action.previousNotes);
      final grid = state.grid.clone()
        ..setValue(action.cellIndex, action.previousValue);
      return state.copyWith(grid: grid, notes: newNotes, history: remaining);
    }(),
    AutoNotesAction() => state.copyWith(
      notes: action.previousNotes.map(Set<int>.from).toList(),
      history: remaining,
    ),
  };
}
