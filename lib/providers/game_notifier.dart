import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/engine/generator.dart';
import 'package:sudoku/domain/engine/solver.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/services/hint_service.dart';
import 'package:sudoku/domain/services/note_service.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';
import 'package:sudoku/domain/services/undo_service.dart';

final solverProvider = Provider<Solver>((ref) => const Solver());

final generatorProvider = Provider<Generator>((ref) {
  final solver = ref.read(solverProvider);
  return Generator(solver);
});

final gameProvider = AsyncNotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

class GameNotifier extends AsyncNotifier<GameState> {
  static const _rules = SudokuRules();
  static const _undo = UndoService();
  static const _notes = NoteService();
  static const _hints = HintService(_rules);

  @override
  Future<GameState> build() async {
    final completer = Completer<GameState>();
    return completer.future;
  }

  Future<void> startGame(Difficulty difficulty) async {
    state = const AsyncLoading();
    final generator = ref.read(generatorProvider);
    final puzzle = await compute(generator.generate, difficulty);
    state = AsyncData(
      GameState.newGame(puzzle: puzzle, difficulty: difficulty),
    );
  }

  void restoreGame(GameState saved) {
    state = AsyncData(
      saved.copyWith(clearSelectedCell: true, inputMode: .digit),
    );
  }

  void selectCell(Cell? cell) => _update(
    (s) => cell == null
        ? s.copyWith(clearSelectedCell: true)
        : s.copyWith(selectedCell: cell),
  );

  void toggleInputMode() => _update(
    (s) => s.copyWith(inputMode: s.inputMode == .digit ? .pencil : .digit),
  );

  void inputDigit(Cell cell, int digit) => _update(
    (s) => s.inputMode == .pencil
        ? _notes.toggle(s, cell, digit)
        : _rules.applyDigit(s, cell, digit),
  );

  void erase(Cell cell) {
    _update((s) {
      if (s.puzzle.isGivenCell(cell)) return s;
      final previousValue = s.board[cell];
      final previousNotes = Set<int>.from(s.notes[cell.index]);
      final action = EraseAction(
        cell: cell,
        previousValue: previousValue,
        previousNotes: previousNotes,
      );
      return _notes
          .clearCell(s, cell)
          .copyWith(
            board: s.board.setCell(cell, 0),
            history: [...s.history, action],
            errorCells: Set.from(s.errorCells)..remove(cell),
          );
    });
  }

  void undo() => _update(_undo.pop);

  void revealCell(Cell cell) => _update((s) => _hints.revealCell(s, cell));

  void validate() => _update(_hints.validate);

  void applyAutoNotes() => _update(_notes.autoFill);

  bool get canUndo {
    final current = state.value;
    if (current == null) return false;
    return _undo.canUndo(current);
  }

  ValidationResult? get validity {
    final current = state.value;
    if (current == null) return null;
    return _hints.validationResult(current);
  }

  void _update(GameState Function(GameState) func) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(func(current));
  }
}
