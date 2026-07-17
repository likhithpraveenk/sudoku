import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_ce/hive.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/stat_record.dart';

final lastCompletionRecordProvider = StateProvider<StatRecord?>(
  (ref) => null,
  name: 'lastCompletionRecordProvider',
);

final statsNotifierProvider =
    NotifierProvider<StatsNotifier, Map<Difficulty, List<StatRecord>>>(
      StatsNotifier.new,
      name: 'statsNotifierProvider',
    );

class StatsNotifier extends Notifier<Map<Difficulty, List<StatRecord>>> {
  Box<List> get _box => Hive.box<List>(statsBox);

  @override
  Map<Difficulty, List<StatRecord>> build() {
    return {for (final d in Difficulty.values) d: _load(_box, d)};
  }

  List<StatRecord> _load(Box<List> box, Difficulty d) {
    final raw = box.get(d.name);
    if (raw == null) return const [];
    return raw
        .map((e) => StatRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void add(StatRecord record) {
    final current = state[record.difficulty] ?? const <StatRecord>[];
    state = {
      ...state,
      record.difficulty: [...current, record],
    };
    unawaited(_persist(record.difficulty));
  }

  Future<void> _persist(Difficulty d) async {
    final list = state[d]!;
    await _box.put(d.name, list.map((r) => r.toJson()).toList());
  }

  Future<void> reset() async {
    await _box.clear();
    state = {for (final d in Difficulty.values) d: const []};
  }

  Future<void> resetPerDifficulty(Difficulty d) async {
    await _box.delete(d.name);
    state = {...state, d: const []};
  }
}

final statsProvider = Provider.family.autoDispose<List<StatRecord>, Difficulty>(
  (ref, difficulty) {
    return ref.watch(statsNotifierProvider)[difficulty] ?? const [];
  },
  name: 'statsProvider',
);

final topStatsProvider = Provider.family
    .autoDispose<
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
