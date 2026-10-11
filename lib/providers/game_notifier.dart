import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/engine/game_engine.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/presentation/shared/input_method.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/game_session.dart';
import 'package:sudoku/providers/services_provider.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/stats_provider.dart';

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

class GameNotifier extends AsyncNotifier<GameState?> {
  GameEngine? _gameEngine;
  GameSession? _session;
  bool _disposed = false;

  @override
  Future<GameState?> build() async {
    final session = GameSession(
      saveGameService: ref.read(saveGameServiceProvider),
      onRecord: _recordCompletion,
      onPersistStat: _persistCompletion,
      onTick: _tick,
    );
    _session = session;

    ref.onDispose(() {
      _disposed = true;
      unawaited(session.dispose());
    });

    final difficulty = ref.read(difficultyProvider);
    final saveGameService = ref.read(saveGameServiceProvider);
    final saved = saveGameService.load(difficulty);
    final initialState = saved ?? await _generateNew(difficulty);

    _gameEngine = GameEngine(initialState);
    session.startTimer();
    return _gameEngine?.currentState;
  }

  Future<GameState> _generateNew(Difficulty difficulty) async {
    final puzzle = await ref
        .read(puzzleGeneratorServiceProvider)
        .generate(difficulty);
    return GameState.newGame(puzzle: puzzle, difficulty: difficulty);
  }

  void startTimer() => _session?.startTimer();

  void pauseTimer() => _session?.pauseTimer();

  Future<void> inputDigit(
    int cellIndex,
    int digit, {
    required InputMode inputMode,
  }) {
    final autoRemoveNotes = ref.read(settingsProvider).autoRemoveNotes;
    return _mutate((engine) {
      if (inputMode == .number) {
        engine.inputDigit(cellIndex, digit, autoRemoveNotes: autoRemoveNotes);
      } else {
        engine.toggleNote(cellIndex, digit);
      }
    });
  }

  Future<void> erase(int cellIndex) =>
      _mutate((engine) => engine.erase(cellIndex));

  Future<void> undo() => _mutate((engine) => engine.undo());

  Future<void> hint() {
    final autoRemoveNotes = ref.read(settingsProvider).autoRemoveNotes;
    return _mutate(
      (engine) => engine.revealHint(autoRemoveNotes: autoRemoveNotes),
    );
  }

  Future<void> runValidation() {
    return _mutate((engine) {
      final errors = engine.findErrors();
      ref.read(boardProvider.notifier).setErrorCells(errors);
    });
  }

  Future<void> applyAutoNotes() => _mutate((engine) => engine.autoFillNotes());

  Future<void> restart() => _mutate((engine) => engine.restart());

  bool get canUndo => _gameEngine?.canUndo == true;

  Future<void> _mutate(void Function(GameEngine engine) operation) async {
    final engine = _gameEngine;
    if (engine == null) return;
    operation(engine);
    await _publish(engine);
  }

  Future<void> _publish(GameEngine engine) async {
    state = AsyncData(engine.currentState);
    await _session?.onMutated(engine.currentState);
  }

  void _tick() {
    if (_disposed) return;
    final engine = _gameEngine;
    if (engine == null) return;
    engine.tick(kTick);
    state = AsyncData(engine.currentState);
  }

  void _recordCompletion(StatRecord record) {
    ref.read(lastCompletionRecordProvider.notifier).state = record;
    ref.read(statsNotifierProvider.notifier).add(record);
  }

  Future<void> _persistCompletion(StatRecord record) async {
    await ref.read(statsNotifierProvider.notifier).persistRecord(record);
  }
}
