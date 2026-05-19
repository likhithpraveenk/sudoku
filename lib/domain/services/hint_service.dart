import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/hint.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

/// The result of grid validation.
enum ValidationResult {
  /// The grid is correct (no errors).
  correct,

  /// The grid contains one or more errors.
  hasErrors,

  /// The grid is complete (all cells correct).
  complete,
}

/// The [revealCell] method.
GameState revealCell(GameState state, int index) {
  if (state.puzzle.isGivenAt(index)) return state;

  final correct = state.puzzle.solution.valueAt(index);
  final newNotes = state.notes.map(Set<int>.from).toList();
  newNotes[index] = {};

  final grid = state.grid.clone()..setValue(index, correct);

  final next = state.copyWith(
    grid: grid,
    notes: newNotes,
    revealedCells: {...state.revealedCells, index},
    errorCells: Set.from(state.errorCells)..remove(index),
  );

  return isSolved(next.grid, next.puzzle.solution)
      ? next.copyWith(isSolved: true)
      : next;
}

/// The [applyLogicalHint] method.
GameState applyLogicalHint(
  GameState state, {
  required void Function(String) onHintFound,
}) {
  final hint = SudokuSolver().getSingleHint(state.grid);
  if (hint == null) {
    // Fall back to revealing the currently selected cell
    final selected = state.selectedCell;
    if (selected != null) {
      onHintFound('Revealed selected cell (Brute-force)');
      return revealCell(state, selected);
    }
    onHintFound('No logical hints available');
    return state;
  }

  // A logical hint is found!
  final difficultyName = hint.getDifficultyLevel().name;
  final desc = hint.description();
  onHintFound('${hint.runtimeType} ($difficultyName) - $desc');

  if (hint is DirectHint) {
    // Set cell value using applyDigit to get all note cleaning, validation,
    // and history actions
    return applyDigit(state, hint.cellIndex, hint.value);
  } else if (hint is IndirectHint) {
    // Eliminate candidates
    final currentNotes = Set<int>.from(state.notes[hint.cellIndex]);
    final updatedNotes = Set<int>.from(currentNotes)
      ..removeAll(hint.valuesToRemove);

    final action = PencilAction(
      cellIndex: hint.cellIndex,
      previousNotes: currentNotes,
      newNotes: updatedNotes,
    );

    final newNotes = state.notes.map(Set<int>.from).toList();
    newNotes[hint.cellIndex] = updatedNotes;

    final nextGrid = state.grid.clone();
    hint.apply(nextGrid);

    return state.copyWith(
      grid: nextGrid,
      notes: newNotes,
      history: [...state.history, action],
    );
  }

  return state;
}

/// The [validate] method.
GameState validate(GameState state) {
  final errors = <int>{};
  for (var i = 0; i < 81; i++) {
    if (state.grid.valueAt(i) != 0 &&
        state.grid.valueAt(i) != state.puzzle.solution.valueAt(i)) {
      errors.add(i);
    }
  }
  return state.copyWith(errorCells: errors);
}

/// The [validationResult] method.
ValidationResult validationResult(GameState state) {
  if (state.isSolved) return ValidationResult.complete;
  for (var i = 0; i < 81; i++) {
    final value = state.grid.valueAt(i);
    if (value != 0 && value != state.puzzle.solution.valueAt(i)) {
      return ValidationResult.hasErrors;
    }
  }
  return ValidationResult.correct;
}
