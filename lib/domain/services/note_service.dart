import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

class NoteService {
  const NoteService();

  GameState toggle(GameState state, Cell cell, int digit) {
    if (state.puzzle.isGivenCell(cell)) return state;
    if (state.revealedCells.contains(cell)) return state;
    if (state.board[cell] != 0) return state;

    final current = Set<int>.from(state.notes[cell.index]);
    final updated = current.contains(digit)
        ? (current..remove(digit))
        : (current..add(digit));

    final action = PencilAction(
      cell: cell,
      previousNotes: Set.from(state.notes[cell.index]),
      newNotes: Set.from(updated),
    );

    final newNotes = state.notes.map(Set<int>.from).toList();
    newNotes[cell.index] = updated;

    return state.copyWith(notes: newNotes, history: [...state.history, action]);
  }

  GameState autoFill(GameState state) {
    final prevNotes = state.notes.map(Set<int>.from).toList();

    final newNotes = List<Set<int>>.generate(81, (i) {
      final cell = Cell.fromIndex(i);
      if (state.board[cell] != 0 || state.puzzle.isGivenCell(cell)) {
        return <int>{};
      }
      final used = {
        ...state.board.valuesOfRow(cell),
        ...state.board.valuesOfCol(cell),
        ...state.board.valuesOfBox(cell),
      }..remove(0);
      return {for (int d = 1; d <= 9; d++) d}..removeAll(used);
    });

    return state.copyWith(
      notes: newNotes,
      history: [
        ...state.history,
        AutoNotesAction(previousNotes: prevNotes),
      ],
    );
  }

  GameState clearCell(GameState state, Cell cell) {
    final newNotes = state.notes.map(Set<int>.from).toList();
    newNotes[cell.index] = {};
    return state.copyWith(notes: newNotes);
  }
}
