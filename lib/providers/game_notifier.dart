import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/board_state.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/services/hint_service.dart';
import 'package:sudoku/domain/services/note_service.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';
import 'package:sudoku/domain/services/undo_service.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';

final puzzleGeneratorServiceProvider = Provider<PuzzleGeneratorService>(
  (ref) => const IsolatePuzzleGeneratorService(),
);

final gameProvider =
    AsyncNotifierProvider.autoDispose<GameNotifier, GameState?>(
      GameNotifier.new,
    );

class GameNotifier extends AsyncNotifier<GameState?> {
  BoardState get board => ref.read(boardProvider);

  @override
  Future<GameState?> build() async {
    final difficulty = ref.read(difficultyProvider);
    final puzzle = await ref
        .read(puzzleGeneratorServiceProvider)
        .generate(difficulty);
    return GameState.newGame(puzzle: puzzle, difficulty: difficulty);
  }

  void restoreGame(GameState saved) {
    state = AsyncData(saved);
  }

  void inputDigit(int cellIndex, int digit) => _update((s) {
    return board.inputMode == .pencil
        ? toggleNote(s, cellIndex, digit)
        : applyDigit(s, cellIndex, digit);
  });

  void erase() {
    _update((s) {
      if (board.selectedCell == null) return s;

      final cellIndex = board.selectedCell!;
      if (s.puzzle.isGivenAt(cellIndex)) return s;

      final previousValue = s.grid.valueAt(cellIndex);
      final previousNotes = Set<int>.from(s.notes[cellIndex]);
      final action = EraseAction(
        cellIndex: cellIndex,
        previousValue: previousValue,
        previousNotes: previousNotes,
      );

      final grid = s.grid.clone()..clearValue(cellIndex);
      final nextState = clearCellNotes(s, cellIndex);

      return nextState.copyWith(grid: grid, history: [...s.history, action]);
    });
  }

  void undo() => _update(popUndo);

  void hint() => _update(revealCell);

  void runValidation() => _update((s) {
    final errors = findErrors(s);
    ref.read(boardProvider.notifier).setErrorCells(errors);
    return s;
  });

  void applyAutoNotes() => _update(autoFillNotes);

  void restart() => _update(
    (s) => s.copyWith(notes: List.generate(81, (_) => {}), history: []),
  );

  void stopTimer() {
    // _timer?.cancel();
    // _timer = null;
  }

  bool get canUndo => state.value?.history.isNotEmpty == true;

  void _update(GameState Function(GameState) func) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(func(current));
  }
}
