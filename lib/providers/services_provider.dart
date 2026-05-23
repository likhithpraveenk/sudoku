import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/data/services/puzzle_generator_service.dart';
import 'package:sudoku/data/services/save_game_service.dart';
import 'package:sudoku/data/services/stats_service.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';

final puzzleGeneratorServiceProvider = Provider<PuzzleGeneratorService>(
  (ref) => const IsolatePuzzleGeneratorService(),
  name: 'puzzleGeneratorServiceProvider',
);

final statsServiceProvider = Provider<StatsService>(
  (ref) => StatsService(),
  name: 'statsServiceProvider',
);

final saveGameServiceProvider = Provider<SaveGameService>(
  (ref) => SaveGameService(),
  name: 'saveGameServiceProvider',
);

final continueGameProvider =
    NotifierProvider<ContinueGameNotifier, Map<Difficulty, GameState?>>(
      ContinueGameNotifier.new,
      name: 'continueGameProvider',
    );

class ContinueGameNotifier extends Notifier<Map<Difficulty, GameState?>> {
  Box<String> get _box => Hive.box(gameBox);

  @override
  Map<Difficulty, GameState?> build() {
    final sub = _box.watch().listen((event) {
      final keyStr = event.key as String;
      final difficulty = Difficulty.values
          .where((d) => d.name == keyStr)
          .firstOrNull;

      if (difficulty != null) {
        GameState? nextState;

        if (!event.deleted && event.value != null) {
          final map = jsonDecode(event.value as String) as Map<String, dynamic>;
          nextState = GameState.fromJson(map);
        }
        state = {...state, difficulty: nextState};
      }
    });

    ref.onDispose(sub.cancel);
    return {for (final d in Difficulty.values) d: _loadState(d)};
  }

  GameState? _loadState(Difficulty d) {
    final raw = _box.get(d.name);
    if (raw == null) return null;
    return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

final statsProvider = Provider.family<List<StatRecord>, Difficulty>((
  ref,
  difficulty,
) {
  return ref.read(statsServiceProvider).getAll(difficulty);
}, name: 'statsProvider');

final topStatsProvider =
    Provider.family<
      ({List<StatRecord> clean, List<StatRecord> assisted}),
      Difficulty
    >((ref, difficulty) {
      final all = ref.watch(statsProvider(difficulty));

      final clean = all.where((r) => r.isClean).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      final assisted = all.where((r) => !r.isClean).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      return (
        clean: clean.take(10).toList(),
        assisted: assisted.take(10).toList(),
      );
    }, name: 'topStatsProvider');
