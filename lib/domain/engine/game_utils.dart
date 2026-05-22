import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_state.dart';

Set<int> peers(int index) => peersOf(index);

bool isConflict(GameState state, int index, int value) {
  if (value == 0) return false;
  return peersOf(index).any((p) => state.grid.valueAt(p) == value);
}

bool isSolved(GameState state) {
  for (var i = 0; i < 81; i++) {
    if (state.grid.valueAt(i) != state.puzzle.solution.valueAt(i)) return false;
  }
  return true;
}

bool isGiven(GameState state, int index) => state.puzzle.isGivenAt(index);

int getValue(GameState state, int index) => state.grid.valueAt(index);

Set<int> getNotes(GameState state, int index) => Set.from(state.notes[index]);

bool hasNotes(GameState state, int index) => state.notes[index].isNotEmpty;
