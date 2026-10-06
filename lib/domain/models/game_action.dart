import 'package:sudoku/domain/models/game_state.dart';

sealed class GameAction {
  const GameAction();
  GameState undo(GameState state);
}

class DigitAction extends GameAction {
  const DigitAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
    required this.newValue,
  });

  final int cellIndex;

  final int previousValue;

  final Map<int, Set<int>> previousNotes;

  final int newValue;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    previousNotes.forEach((i, notes) {
      newNotes[i] = Set<int>.from(notes);
    });
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }
}

class PencilAction extends GameAction {
  const PencilAction({
    required this.cellIndex,
    required this.previousNotes,
    required this.newNotes,
    required this.previousValue,
  });

  final int cellIndex;

  final Set<int> previousNotes;

  final Set<int> newNotes;

  final int previousValue;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    newNotes[cellIndex] = Set<int>.from(previousNotes);
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }
}

class EraseAction extends GameAction {
  const EraseAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
  });

  final int cellIndex;

  final int previousValue;

  final Set<int> previousNotes;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    newNotes[cellIndex] = Set<int>.from(previousNotes);
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }
}

class AutoNotesAction extends GameAction {
  const AutoNotesAction({required this.previousNotes});

  final List<Set<int>> previousNotes;

  @override
  GameState undo(GameState state) {
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(
      notes: previousNotes.map(Set<int>.from).toList(),
      history: trimmed,
    );
  }
}
