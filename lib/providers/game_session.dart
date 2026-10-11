import 'dart:async';

import 'package:sudoku/data/services/save_game_service.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';

const kTick = Duration(seconds: 1);

class GameSession {
  GameSession({
    required this._saveGameService,
    required this._onRecord,
    required this._onPersistStat,
    required this._onTick,
  });

  final SaveGameService _saveGameService;
  final void Function(StatRecord record) _onRecord;
  final Future<void> Function(StatRecord record) _onPersistStat;
  final void Function() _onTick;

  Timer? _timer;
  GameState? _state;
  bool _complete = false;
  Future<void> _queue = Future<void>.value();

  Future<void> onMutated(GameState state) {
    _state = state;
    if (state.puzzleComplete) return onCompleted(state);
    _complete = false;
    return _enqueue(() => _saveGameService.save(state));
  }

  Future<void> onCompleted(GameState completed) {
    _state = completed;
    if (_complete) return Future<void>.value();
    _complete = true;
    _timer?.cancel();
    final record = StatRecord.fromGameState(completed);
    _onRecord(record);
    return _enqueue(() async {
      await _onPersistStat(record);
      await _saveGameService.delete(completed.difficulty);
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(kTick, (_) {
      if (_complete) return;
      _onTick();
    });
  }

  void pauseTimer() => _timer?.cancel();

  Future<void> dispose() {
    _timer?.cancel();
    final state = _state;
    if (state == null) return Future<void>.value();
    return state.puzzleComplete
        ? _enqueue(() => _saveGameService.delete(state.difficulty))
        : _enqueue(() => _saveGameService.save(state));
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final tail = _queue.then((_) => operation()).onError<Object>((_, _) {});
    _queue = tail;
    return tail;
  }
}
