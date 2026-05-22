import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/data/services/puzzle_generator_service.dart';
import 'package:sudoku/domain/engine/game_engine.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/presentation/models/board_state.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';

final puzzleGeneratorServiceProvider = Provider<PuzzleGeneratorService>(
  (ref) => const IsolatePuzzleGeneratorService(),
);

final gameProvider = AsyncNotifierProvider.autoDispose(GameNotifier.new);

class GameNotifier extends AsyncNotifier<GameState?> {
  BoardState get board => ref.read(boardProvider);
  late GameEngine _gameEngine;
  Timer? _timer;

  @override
  Future<GameState?> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });
    final difficulty = ref.read(difficultyProvider);
    final puzzle = await ref
        .read(puzzleGeneratorServiceProvider)
        .generate(difficulty);
    final initialState = GameState.newGame(
      puzzle: puzzle,
      difficulty: difficulty,
    );
    _gameEngine = GameEngine(initialState);
    _startTimer();
    return _gameEngine.currentState;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _gameEngine.tick();
      state = AsyncData(_gameEngine.currentState);
    });
  }

  void saveGame() {
    _timer?.cancel();
    _timer = null;
    // TODO: another hive box for saved games?
  }

  void restoreGame(GameState saved) {
    _gameEngine = GameEngine(saved);
    _startTimer();
    state = AsyncData(_gameEngine.currentState);
  }

  void inputDigit(int cellIndex, int digit) {
    if (board.inputMode == .number) {
      _gameEngine.inputDigit(cellIndex, digit);
    } else {
      _gameEngine.toggleNote(cellIndex, digit);
    }
    state = AsyncData(_gameEngine.currentState);
  }

  void erase() {
    if (board.selectedCell == null) return;
    _gameEngine.erase(board.selectedCell!);
    state = AsyncData(_gameEngine.currentState);
  }

  void undo() {
    _gameEngine.undo();
    state = AsyncData(_gameEngine.currentState);
  }

  void hint() {
    _gameEngine.revealHint();
    state = AsyncData(_gameEngine.currentState);
  }

  void runValidation() {
    final errors = _gameEngine.findErrors();
    ref.read(boardProvider.notifier).setErrorCells(errors);
    state = AsyncData(_gameEngine.currentState);
  }

  void applyAutoNotes() {
    _gameEngine.autoFillNotes();
    state = AsyncData(_gameEngine.currentState);
  }

  void restart() {
    final currentState = _gameEngine.currentState;
    final newState = GameState.newGame(
      puzzle: currentState.puzzle,
      difficulty: currentState.difficulty,
    );
    _gameEngine = GameEngine(newState);
    state = AsyncData(_gameEngine.currentState);
  }

  bool get canUndo => _gameEngine.canUndo;
}
