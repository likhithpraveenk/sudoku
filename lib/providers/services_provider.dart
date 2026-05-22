import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sudoku/data/services/puzzle_generator_service.dart';
import 'package:sudoku/data/services/save_game_service.dart';
import 'package:sudoku/data/services/stats_service.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/domain/services/puzzle_generator_service.dart';
import 'package:sudoku/providers/difficulty_provider.dart';

final puzzleGeneratorServiceProvider = Provider<PuzzleGeneratorService>(
  (ref) => const IsolatePuzzleGeneratorService(),
);

final statsServiceProvider = Provider<StatsService>((ref) => StatsService());

final saveGameServiceProvider = Provider<SaveGameService>(
  (ref) => SaveGameService(),
);

final continueGameFlagProvider = StateProvider<bool>((ref) => false);

final continueGameProvider = FutureProvider<GameState?>((ref) {
  final difficulty = ref.watch(difficultyProvider);
  final service = ref.read(saveGameServiceProvider);
  return Future.value(service.load(difficulty));
});

final statsProvider = Provider.family<List<StatRecord>, Difficulty>((
  ref,
  difficulty,
) {
  return ref.read(statsServiceProvider).getAll(difficulty);
});

final topStatsProvider =
    Provider.family<
      ({List<StatRecord> clean, List<StatRecord> assisted}),
      Difficulty
    >((ref, difficulty) {
      final all = ref.watch(statsProvider(difficulty));

      final clean = all.where((r) => r.isClean).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      // TODO: separate assists?

      final assisted = all.where((r) => !r.isClean).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      return (
        clean: clean.take(10).toList(),
        assisted: assisted.take(10).toList(),
      );
    });
