import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/stat_record.dart';

class StatsService {
  StatsService() : _box = Hive.box(statsBox);

  final Box<List> _box;

  static String _key(Difficulty difficulty) => difficulty.name;

  Future<void> save(StatRecord record) async {
    final existing = getAll(record.difficulty);
    final updated = [...existing, record];
    await _box.put(
      _key(record.difficulty),
      updated.map((r) => r.toJson()).toList(),
    );
  }

  List<StatRecord> getAll(Difficulty difficulty) {
    final raw = _box.get(_key(difficulty));
    if (raw == null) return [];
    return raw
        .map((e) => StatRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> reset() => _box.clear();
}
