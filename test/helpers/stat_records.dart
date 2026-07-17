import 'dart:math';

import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/stat_record.dart';

class TestStatRecords {
  const TestStatRecords._();

  static StatRecord record({
    Difficulty difficulty = .easy,
    int seconds = 60,
    bool hints = false,
    bool autoNotes = false,
    bool validation = false,
    int epochMs = 0,
  }) => StatRecord(
    difficulty: difficulty,
    time: Duration(seconds: seconds),
    usedHints: hints,
    usedAutoNotes: autoNotes,
    usedValidation: validation,
    completedAt: DateTime.fromMillisecondsSinceEpoch(epochMs),
  );

  static StatRecord easyClean() =>
      record(difficulty: .easy, seconds: 95, epochMs: 1000);

  static StatRecord easyAssisted() =>
      record(difficulty: .easy, seconds: 140, hints: true, epochMs: 2000);

  static StatRecord mediumClean() =>
      record(difficulty: .medium, seconds: 210, epochMs: 3000);

  static StatRecord mediumAssisted() =>
      record(difficulty: .medium, seconds: 260, autoNotes: true, epochMs: 4000);

  static StatRecord hardClean() =>
      record(difficulty: .hard, seconds: 480, epochMs: 5000);

  static StatRecord hardAssisted() =>
      record(difficulty: .hard, seconds: 620, validation: true, epochMs: 6000);

  static StatRecord expertClean() =>
      record(difficulty: .expert, seconds: 900, epochMs: 7000);

  static StatRecord expertAssisted() => record(
    difficulty: .expert,
    seconds: 1500,
    hints: true,
    autoNotes: true,
    validation: true,
    epochMs: 8000,
  );

  static List<StatRecord> all() => [
    easyClean(),
    easyAssisted(),
    mediumClean(),
    mediumAssisted(),
    hardClean(),
    hardAssisted(),
    expertClean(),
    expertAssisted(),
  ];

  static Map<Difficulty, List<StatRecord>> byDifficulty() {
    final map = <Difficulty, List<StatRecord>>{};
    for (final record in all()) {
      (map[record.difficulty] ??= <StatRecord>[]).add(record);
    }
    return map;
  }

  static List<StatRecord> randomForDifficulty(
    Difficulty difficulty, {
    int count = 50,
    double assistedRatio = 0.4,
    int? seed,
  }) {
    final random = Random(seed);

    final baseSeconds = switch (difficulty) {
      .easy => 50,
      .medium => 120,
      .hard => 240,
      .expert => 400,
    };
    final spread = baseSeconds;
    final now = DateTime.now();

    return List<StatRecord>.generate(count, (i) {
      final seconds = baseSeconds + random.nextInt(spread + 1);
      final assisted = random.nextDouble() < assistedRatio;

      var hints = false;
      var autoNotes = false;
      var validation = false;
      if (assisted) {
        while (!hints && !autoNotes && !validation) {
          hints = random.nextBool();
          autoNotes = random.nextBool();
          validation = random.nextBool();
        }
      }

      final completedAt = now.subtract(
        Duration(
          days: random.nextInt(count),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        ),
      );

      return record(
        difficulty: difficulty,
        seconds: seconds,
        hints: hints,
        autoNotes: autoNotes,
        validation: validation,
        epochMs: completedAt.millisecondsSinceEpoch,
      );
    });
  }
}
