import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/stats_provider.dart';

import '../helpers/fake_services.dart';

StatRecord _record({
  Difficulty difficulty = Difficulty.easy,
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

ProviderContainer _makeContainer({
  Difficulty difficulty = Difficulty.easy,
  FakeStatsService? statsService,
}) {
  return ProviderContainer(
    overrides: [
      statsNotifierProvider.overrideWith(
        () => _TestStatsNotifier(statsService?.seed ?? {}),
      ),
      difficultyProvider.overrideWith(() => FakeDifficultyNotifier(difficulty)),
    ],
  );
}

class _TestStatsNotifier extends StatsNotifier {
  _TestStatsNotifier(this._seed);
  final Map<Difficulty, List<StatRecord>> _seed;

  @override
  Map<Difficulty, List<StatRecord>> build() => _seed;
}

void main() {
  group('statsProvider', () {
    test('returns empty list when no records', () {
      final container = _makeContainer();
      final records = container.read(statsProvider(Difficulty.medium));
      expect(records, isEmpty);
      container.dispose();
    });

    test('returns records stored for the difficulty', () async {
      final stats = FakeStatsService();
      await stats.save(_record(difficulty: Difficulty.medium, seconds: 90));
      await stats.save(_record(difficulty: Difficulty.medium, seconds: 120));
      await stats.save(_record(difficulty: Difficulty.easy, seconds: 30));

      final container = _makeContainer(statsService: stats);

      final medium = container.read(statsProvider(Difficulty.medium));
      expect(medium, hasLength(2));
      expect(medium.first.time, const Duration(seconds: 90));

      final easy = container.read(statsProvider(Difficulty.easy));
      expect(easy, hasLength(1));
      container.dispose();
    });
  });

  group('topStatsProvider', () {
    test('partitions clean vs assisted and returns fastest 10 each', () async {
      final stats = FakeStatsService();
      for (int i = 0; i < 15; i++) {
        await stats.save(
          _record(
            difficulty: .hard,
            seconds: 300 - i * 5,
            hints: i >= 10,
            epochMs: i,
          ),
        );
      }

      final container = _makeContainer(difficulty: .hard, statsService: stats);

      final top = container.read(topStatsProvider(.hard));

      expect(top.clean.length, 10);
      expect(top.assisted.length, 5);
      expect(
        top.clean.first.time.inSeconds,
        lessThan(top.clean.last.time.inSeconds),
      );
      expect(top.clean.every((r) => r.isClean), isTrue);
      expect(top.assisted.every((r) => !r.isClean), isTrue);
      container.dispose();
    });

    test('sorts independently and limits to 10', () async {
      final stats = FakeStatsService();
      await stats.save(_record(seconds: 200, hints: true));
      await stats.save(_record(seconds: 50, hints: false));
      await stats.save(_record(seconds: 100, hints: true));
      await stats.save(_record(seconds: 75, hints: false));

      final container = _makeContainer(statsService: stats);

      final top = container.read(topStatsProvider(Difficulty.easy));
      expect(top.clean, hasLength(2));
      expect(top.clean[0].time.inSeconds, 50);
      expect(top.clean[1].time.inSeconds, 75);
      expect(top.assisted, hasLength(2));
      expect(top.assisted[0].time.inSeconds, 100);
      expect(top.assisted[1].time.inSeconds, 200);
      container.dispose();
    });
  });

  group('statsNotifierProvider', () {
    test('resolves', () {
      final container = _makeContainer();
      expect(
        container.read(statsNotifierProvider),
        isA<Map<Difficulty, List<StatRecord>>>(),
      );
      container.dispose();
    });
  });
}
