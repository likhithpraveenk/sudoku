import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/domain/services/hint_service.dart' as hints;
import 'package:sudoku/domain/services/note_service.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/domain/services/sudoku_rules.dart';
import 'package:sudoku/domain/services/undo_service.dart';

/// A public member.
final puzzleGeneratorServiceProvider = Provider<PuzzleGeneratorService>(
  (ref) => const IsolatePuzzleGeneratorService(),
);

/// A public member.
final gameProvider = AsyncNotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

/// [GameNotifier] definition.
class GameNotifier extends AsyncNotifier<GameState> {
  @override
  Future<GameState> build() async {
    final completer = Completer<GameState>();
    return completer.future;
  }

  /// A public member.
  Future<void> startGame(Difficulty difficulty) async {
    state = const AsyncLoading();
    final puzzle = await ref
        .read(puzzleGeneratorServiceProvider)
        .generate(difficulty);
    log('puzzle: ${puzzle.grid.values}');
    state = AsyncData(
      GameState.newGame(puzzle: puzzle, difficulty: difficulty),
    );
  }

  /// The [restoreGame] method.
  void restoreGame(GameState saved) {
    state = AsyncData(
      saved.copyWith(clearSelectedCell: true, inputMode: InputMode.digit),
    );
  }

  /// The [selectCell] method.
  void selectCell(int? cellIndex) => _update((s) {
    // Digit First Workflow: if a global digit is selected, fill notes/digits freely without selecting the cell
    if (s.selectedDigit != null) {
      if (cellIndex == null || s.puzzle.isGivenAt(cellIndex)) {
        return s;
      }
      final nextState = s.inputMode == InputMode.pencil
          ? toggleNote(s, cellIndex, s.selectedDigit!)
          : applyDigit(s, cellIndex, s.selectedDigit!);
      return nextState.copyWith(clearSelectedCell: true);
    }

    // Normal Cell First Workflow
    if (cellIndex == null) {
      return s.copyWith(clearSelectedCell: true);
    }
    if (s.selectedCell == cellIndex) {
      return s.copyWith(clearSelectedCell: true);
    }
    return s.copyWith(selectedCell: cellIndex, clearSelectedDigit: true);
  });

  /// The [selectDigit] method.
  void selectDigit(int? digit) => _update(
    (s) => digit == null
        ? s.copyWith(clearSelectedDigit: true)
        : (s.selectedDigit == digit
              ? s.copyWith(clearSelectedDigit: true)
              : s.copyWith(selectedDigit: digit, clearSelectedCell: true)),
  );

  /// The [pressDigit] method.
  void pressDigit(int digit) => _update((s) {
    // Cell First Workflow: if a cell is selected, place notes/digits in the cell and keep the cell selected
    if (s.selectedCell != null) {
      if (s.puzzle.isGivenAt(s.selectedCell!)) {
        return s;
      }
      final nextState = s.inputMode == InputMode.pencil
          ? toggleNote(s, s.selectedCell!, digit)
          : applyDigit(s, s.selectedCell!, digit);
      return nextState.copyWith(clearSelectedDigit: true);
    }

    // Digit First Workflow: toggle global digit selection
    if (s.selectedDigit == digit) {
      return s.copyWith(clearSelectedDigit: true);
    }
    return s.copyWith(selectedDigit: digit, clearSelectedCell: true);
  });

  /// The [toggleInputMode] method.
  void toggleInputMode() => _update(
    (s) => s.copyWith(
      inputMode: s.inputMode == InputMode.digit
          ? InputMode.pencil
          : InputMode.digit,
    ),
  );

  /// The [inputDigit] method.
  void inputDigit(int cellIndex, int digit) => _update(
    (s) => s.inputMode == InputMode.pencil
        ? toggleNote(s, cellIndex, digit)
        : applyDigit(s, cellIndex, digit),
  );

  /// The [erase] method.
  void erase(int cellIndex) {
    _update((s) {
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

      return nextState.copyWith(
        grid: grid,
        history: [...s.history, action],
        errorCells: Set.from(s.errorCells)..remove(cellIndex),
      );
    });
  }

  /// The [undo] method.
  void undo() => _update(popUndo);

  /// The [applyHint] method.
  void applyHint(void Function(String) onHintMessage) =>
      _update((s) => hints.applyLogicalHint(s, onHintFound: onHintMessage));

  /// The [revealCell] method.
  void revealCell(int cellIndex) =>
      _update((s) => hints.revealCell(s, cellIndex));

  /// The [runValidation] method.
  void runValidation() => _update(hints.validate);

  /// The [applyAutoNotes] method.
  void applyAutoNotes() => _update(autoFillNotes);

  /// The [canUndo] getter.
  bool get canUndo {
    final current = state.value;
    if (current == null) return false;
    return current.history.isNotEmpty;
  }

  /// The [validity] getter.
  hints.ValidationResult? get validity {
    final current = state.value;
    if (current == null) return null;
    return hints.validationResult(current);
  }

  void _update(GameState Function(GameState) func) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(func(current));
  }
}
