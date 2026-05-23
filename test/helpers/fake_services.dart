import 'package:sudoku/data/services/save_game_service.dart';
import 'package:sudoku/data/services/stats_service.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/providers/difficulty_provider.dart';

class FakeSaveGameService implements SaveGameService {
  final Map<Difficulty, GameState> _store = {};
  final List<Difficulty> deletedDifficulties = [];
  int saveCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> save(GameState state) async {
    saveCalls++;
    _store[state.difficulty] = state;
  }

  @override
  GameState? load(Difficulty difficulty) => _store[difficulty];

  @override
  Future<void> delete(Difficulty difficulty) async {
    deleteCalls++;
    deletedDifficulties.add(difficulty);
    _store.remove(difficulty);
  }

  @override
  bool hasSavedGame(Difficulty difficulty) => _store[difficulty] != null;

  GameState? savedFor(Difficulty difficulty) => _store[difficulty];
}

class FakeStatsService implements StatsService {
  final Map<Difficulty, List<StatRecord>> _store = {};
  int saveCalls = 0;

  @override
  List<StatRecord> getAll(Difficulty difficulty) =>
      List<StatRecord>.from(_store[difficulty] ?? const []);

  @override
  Future<void> save(StatRecord record) async {
    saveCalls++;
    (_store[record.difficulty] ??= <StatRecord>[]).add(record);
  }

  @override
  Future<void> reset() async => _store.clear();
}

class FakeDifficultyNotifier extends DifficultyProvider {
  FakeDifficultyNotifier(this._difficulty);
  final Difficulty _difficulty;

  @override
  Difficulty build() => _difficulty;
}
