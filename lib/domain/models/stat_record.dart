import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';

class StatRecord {
  const StatRecord({
    required this.difficulty,
    required this.time,
    required this.usedHints,
    required this.usedAutoNotes,
    required this.usedValidation,
    required this.completedAt,
  });

  final Difficulty difficulty;
  final Duration time;
  final bool usedHints;
  final bool usedAutoNotes;
  final bool usedValidation;
  final DateTime completedAt;

  bool get isClean => !usedHints && !usedAutoNotes && !usedValidation;

  factory StatRecord.fromGameState(GameState state) => StatRecord(
    difficulty: state.difficulty,
    time: state.elapsed,
    usedHints: state.assists.hints,
    usedAutoNotes: state.assists.autoNotes,
    usedValidation: state.assists.validation,
    completedAt: DateTime.now(),
  );

  factory StatRecord.fromJson(Map<String, dynamic> json) => StatRecord(
    difficulty: Difficulty.fromValue(json['difficulty'] as int),
    time: Duration(seconds: json['time'] as int),
    usedHints: json['usedHints'] as bool,
    usedAutoNotes: json['usedAutoNotes'] as bool,
    usedValidation: json['usedValidation'] as bool,
    completedAt: DateTime.fromMillisecondsSinceEpoch(
      json['completedAt'] as int,
    ),
  );

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty.value,
    'time': time.inSeconds,
    'usedHints': usedHints,
    'usedAutoNotes': usedAutoNotes,
    'usedValidation': usedValidation,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  String get assistsUsed {
    final list = <String>[];
    if (usedHints) {
      list.add('Hint');
    }
    if (usedAutoNotes) {
      list.add('Auto notes');
    }
    if (usedValidation) {
      list.add('Validation');
    }
    return list.join(', ');
  }

  @override
  String toString() => toJson().toString();
}
