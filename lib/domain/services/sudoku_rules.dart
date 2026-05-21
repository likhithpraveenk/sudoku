import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';
import 'package:sudoku/domain/services/note_service.dart';

Set<int> peers(SudokuGrid grid, int index) {
  return peersOf(index);
}

bool isConflict(SudokuGrid grid, int index, int value) {
  if (value == 0) return false;
  return peers(grid, index).any((p) => grid.valueAt(p) == value);
}

bool isSolved(SudokuGrid grid, SudokuGrid solution) {
  for (var i = 0; i < 81; i++) {
    if (grid.valueAt(i) != solution.valueAt(i)) return false;
  }
  return true;
}

GameState applyDigit(GameState state, int index, int value) {
  if (state.puzzle.isGivenAt(index)) return state;
  if (state.grid.valueAt(index) == value) {
    final grid = state.grid.clone()..clearValue(index);
    final nextState = clearCellNotes(state, index);
    return nextState.copyWith(grid: grid);
  }

  final previousNotes = <int, Set<int>>{};
  final newNotes = state.notes.map(Set<int>.from).toList();

  if (value != 0) {
    for (final peerIndex in peersOf(index)) {
      previousNotes[peerIndex] = Set.from(state.notes[peerIndex]);
      newNotes[peerIndex].remove(value);
    }
  }
  newNotes[index].clear();

  final action = DigitAction(
    cellIndex: index,
    previousValue: state.grid.valueAt(index),
    newValue: value,
    previousNotes: previousNotes,
  );

  final nextGrid = state.grid.clone()..setValue(index, value);

  final next = state.copyWith(
    grid: nextGrid,
    notes: newNotes,
    history: [...state.history, action],
  );

  return isSolved(next.grid, next.puzzle.solution)
      ? next.copyWith(puzzleComplete: true)
      : next;
}
