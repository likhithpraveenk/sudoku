import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// A public member.
Set<int> peers(SudokuGrid grid, int index) {
  return peersOf(index);
}

/// The [isConflict] method.
bool isConflict(SudokuGrid grid, int index, int value) {
  if (value == 0) return false;
  return peers(grid, index).any((p) => grid.valueAt(p) == value);
}

/// The [isSolved] method.
bool isSolved(SudokuGrid grid, SudokuGrid solution) {
  for (var i = 0; i < 81; i++) {
    if (grid.valueAt(i) != solution.valueAt(i)) return false;
  }
  return true;
}

/// The [applyDigit] method.
GameState applyDigit(GameState state, int index, int value) {
  if (state.puzzle.isGivenAt(index)) return state;

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

  final isWrong = value != 0 && value != state.puzzle.solution.valueAt(index);
  final newErrors = Set<int>.from(state.errorCells);
  isWrong ? newErrors.add(index) : newErrors.remove(index);

  final nextGrid = state.grid.clone()..setValue(index, value);

  final next = state.copyWith(
    grid: nextGrid,
    notes: newNotes,
    history: [...state.history, action],
    errorCells: newErrors,
    mistakeCount: isWrong ? state.mistakeCount + 1 : state.mistakeCount,
  );

  return isSolved(next.grid, next.puzzle.solution)
      ? next.copyWith(isSolved: true)
      : next;
}
