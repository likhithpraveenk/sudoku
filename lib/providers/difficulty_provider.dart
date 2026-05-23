import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';

final difficultyProvider = NotifierProvider(
  DifficultyProvider.new,
  name: 'difficultyProvider',
);

class DifficultyProvider extends Notifier<Difficulty> {
  @override
  Difficulty build() => .easy;

  void set(Difficulty difficulty) => state = difficulty;
}
