import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/engine/game_engine.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/presentation/models/board_state.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/services_provider.dart';
import 'package:sudoku/providers/settings_provider.dart';

final gameProvider =
    AsyncNotifierProvider.autoDispose<GameNotifier, GameState?>(
      GameNotifier.new,
      name: 'gameProvider',
    );

final isFinishedProvider = Provider.autoDispose((ref) {
  final puzzleComplete = ref.watch(
    gameProvider.select((s) => s.value?.puzzleComplete),
  );
  return puzzleComplete == true;
}, name: 'isFinishedProvider');

const kTick = Duration(seconds: 1);

class GameNotifier extends AsyncNotifier<GameState?> {
  late GameEngine _gameEngine;
  Timer? _timer;
  StatRecord? lastRecord;

  BoardState get board => ref.read(boardProvider);

  @override
  Future<GameState?> build() async {
    final saveGameService = ref.read(saveGameServiceProvider);
    ref.onDispose(() {
      _timer?.cancel();
      final current = _gameEngine.currentState;
      if (current.puzzleComplete) {
        saveGameService.delete(current.difficulty);
      } else {
        saveGameService.save(current);
      }
    });

    final difficulty = ref.read(difficultyProvider);
    final saved = saveGameService.load(difficulty);
    final initialState = saved ?? await _generateNew(difficulty);

    _gameEngine = GameEngine(initialState);
    _startTimer();
    return _gameEngine.currentState;
  }

  Future<GameState> _generateNew(Difficulty difficulty) async {
    final puzzle = await ref
        .read(puzzleGeneratorServiceProvider)
        .generate(difficulty);
    return GameState.newGame(puzzle: puzzle, difficulty: difficulty);
  }

  void _startTimer() {
    _timer = Timer.periodic(kTick, (_) {
      _gameEngine.tick(kTick);
      state = AsyncData(_gameEngine.currentState);
    });
  }

  void inputDigit(int cellIndex, int digit) {
    if (board.inputMode == .number) {
      final autoRemoveNotes = ref.read(settingsProvider).autoRemoveNotes;
      _gameEngine.inputDigit(
        cellIndex,
        digit,
        autoRemoveNotes: autoRemoveNotes,
      );
    } else {
      _gameEngine.toggleNote(cellIndex, digit);
    }
    state = AsyncData(_gameEngine.currentState);
    if (_gameEngine.currentState.puzzleComplete) {
      _onPuzzleComplete(_gameEngine.currentState);
    }
  }

  void erase([int? index]) {
    if (index != null) {
      _gameEngine.erase(index);
    } else if (board.selectedCell != null) {
      _gameEngine.erase(board.selectedCell!);
    }
    state = AsyncData(_gameEngine.currentState);
  }

  void undo() {
    _gameEngine.undo();
    state = AsyncData(_gameEngine.currentState);
  }

  void hint() {
    final autoRemoveNotes = ref.read(settingsProvider).autoRemoveNotes;
    _gameEngine.revealHint(autoRemoveNotes: autoRemoveNotes);
    state = AsyncData(_gameEngine.currentState);
    if (_gameEngine.currentState.puzzleComplete) {
      _onPuzzleComplete(_gameEngine.currentState);
    }
  }

  void _onPuzzleComplete(GameState completed) {
    _timer?.cancel();
    lastRecord = StatRecord.fromGameState(completed);
    ref.read(statsServiceProvider).save(lastRecord!);
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
