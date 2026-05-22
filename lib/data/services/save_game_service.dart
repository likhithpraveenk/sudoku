import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';

class SaveGameService {
  SaveGameService() : _box = Hive.box(gameBox);

  final Box<String> _box;

  Future<void> save(GameState state) async {
    await _box.put(state.difficulty.name, jsonEncode(state));
  }

  GameState? load(Difficulty difficulty) {
    final raw = _box.get(difficulty.name);
    if (raw == null) return null;
    return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> delete(Difficulty difficulty) => _box.delete(difficulty.name);

  bool hasSavedGame(Difficulty difficulty) => _box.containsKey(difficulty.name);
}
