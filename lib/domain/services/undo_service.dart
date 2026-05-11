import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

class UndoService {
  const UndoService();

  bool canUndo(GameState state) => state.history.isNotEmpty;

  GameState pop(GameState state) {
    if (!canUndo(state)) return state;

    final action = state.history.last;
    final remaining = state.history.sublist(0, state.history.length - 1);

    return switch (action) {
      DigitAction() => state.copyWith(
        board: state.board.setCell(action.cell, action.previousValue),
        history: remaining,
        errorCells: Set.from(state.errorCells)..remove(action.cell),
      ),
      PencilAction() => () {
        final newNotes = state.notes.map(Set<int>.from).toList();
        newNotes[action.cell.index] = Set.from(action.previousNotes);
        return state.copyWith(notes: newNotes, history: remaining);
      }(),
      EraseAction() => () {
        final newNotes = state.notes.map(Set<int>.from).toList();
        newNotes[action.cell.index] = Set.from(action.previousNotes);
        return state.copyWith(
          board: state.board.setCell(action.cell, action.previousValue),
          notes: newNotes,
          history: remaining,
        );
      }(),
      AutoNotesAction() => state.copyWith(
        notes: action.previousNotes.map(Set<int>.from).toList(),
        history: remaining,
      ),
    };
  }
}
