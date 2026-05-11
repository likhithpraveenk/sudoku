import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';

enum ValidationResult { correct, hasErrors, complete }

class HintService {
  const HintService(this._rules);
  final SudokuRules _rules;

  GameState revealCell(GameState state, Cell cell) {
    if (state.puzzle.isGivenCell(cell)) return state;

    final correct = state.puzzle.solution[cell];
    final newNotes = state.notes.map(Set<int>.from).toList();
    newNotes[cell.index] = {};

    final next = state.copyWith(
      board: state.board.setCell(cell, correct),
      notes: newNotes,
      revealedCells: {...state.revealedCells, cell},
      errorCells: Set.from(state.errorCells)..remove(cell),
    );

    return _rules.isSolved(next.board, next.puzzle.solution)
        ? next.copyWith(isSolved: true)
        : next;
  }

  GameState validate(GameState state) {
    final errors = <Cell>{
      for (final cell in Board.allCells)
        if (state.board[cell] != 0 &&
            state.board[cell] != state.puzzle.solution[cell])
          cell,
    };
    return state.copyWith(errorCells: errors);
  }

  ValidationResult validationResult(GameState state) {
    if (state.isSolved) return .complete;
    final hasErrors = Board.allCells.any((cell) {
      final value = state.board[cell];
      return value != 0 && value != state.puzzle.solution[cell];
    });
    return hasErrors ? .hasErrors : .correct;
  }
}
