import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

GameState revealCell(GameState state) {
  final result = firstEmptyOrWrong(
    state.grid.values,
    state.puzzle.solution.values,
  );
  if (result == null) return state;

  return applyDigit(state, result.index, result.correct);
}

Set<int> findErrors(GameState state) {
  final errors = <int>{};
  for (var i = 0; i < 81; i++) {
    if (state.grid.valueAt(i) != 0 &&
        state.grid.valueAt(i) != state.puzzle.solution.valueAt(i)) {
      errors.add(i);
    }
  }
  return errors;
}
