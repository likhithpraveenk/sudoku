import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/services_provider.dart';

import '../helpers/fake_services.dart';
import '../helpers/sudoku_grids.dart';

ProviderContainer _makeContainer({
  Difficulty difficulty = Difficulty.easy,
  FakeSaveGameService? saveService,
  Map<Difficulty, GameState?>? continueGames,
}) {
  return ProviderContainer(
    overrides: [
      saveGameServiceProvider.overrideWithValue(
        saveService ?? FakeSaveGameService(),
      ),
      difficultyProvider.overrideWith(() => FakeDifficultyNotifier(difficulty)),
      if (continueGames != null)
        continueGameProvider.overrideWith(
          () => _FakeContinueGameNotifier(continueGames),
        ),
    ],
  );
}

class _FakeContinueGameNotifier extends ContinueGameNotifier {
  _FakeContinueGameNotifier(this._value);
  final Map<Difficulty, GameState?> _value;

  @override
  Map<Difficulty, GameState?> build() => _value;
}

void main() {
  group('continueGameProvider', () {
    test('returns null when no saved game for difficulty', () async {
      final container = _makeContainer(
        continueGames: {for (final d in Difficulty.values) d: null},
      );
      final map = container.read(continueGameProvider);

      expect(map[Difficulty.easy], isNull);
      container.dispose();
    });

    test('returns saved game for current difficulty', () async {
      final saved = GameState.newGame(
        puzzle: Puzzle(
          given: TestGrids.simplePuzzle(),
          solution: TestGrids.simpleSolution(),
        ),
        difficulty: Difficulty.easy,
      ).copyWith(elapsed: const Duration(seconds: 42));

      final container = _makeContainer(
        continueGames: {
          Difficulty.easy: saved,
          for (final d in Difficulty.values)
            if (d != Difficulty.easy) d: null,
        },
      );

      final map = container.read(continueGameProvider);
      final result = map[Difficulty.easy];

      expect(result, isNotNull);
      expect(result!.elapsed, const Duration(seconds: 42));
      container.dispose();
    });

    test('returns different saved game after difficulty change', () async {
      final easySaved = GameState.newGame(
        puzzle: Puzzle(
          given: TestGrids.simplePuzzle(),
          solution: TestGrids.simpleSolution(),
        ),
        difficulty: .easy,
      ).copyWith(elapsed: const Duration(seconds: 10));

      final hardSaved = GameState.newGame(
        puzzle: Puzzle(
          given: TestGrids.simplePuzzle(),
          solution: TestGrids.simpleSolution(),
        ),
        difficulty: .hard,
      ).copyWith(elapsed: const Duration(minutes: 2));

      final container = _makeContainer(
        difficulty: .easy,
        continueGames: {
          Difficulty.easy: easySaved,
          Difficulty.hard: hardSaved,
          for (final d in Difficulty.values)
            if (d != Difficulty.easy && d != Difficulty.hard) d: null,
        },
      );

      var map = container.read(continueGameProvider);

      expect(map[Difficulty.easy]!.elapsed, const Duration(seconds: 10));

      container.read(difficultyProvider.notifier).set(Difficulty.hard);
      map = container.read(continueGameProvider);

      expect(map[Difficulty.hard]!.elapsed, const Duration(minutes: 2));

      container.dispose();
    });
  });

  group('service providers', () {
    test('saveGameServiceProvider resolves', () {
      final save = FakeSaveGameService();
      final container = ProviderContainer(
        overrides: [saveGameServiceProvider.overrideWithValue(save)],
      );
      expect(container.read(saveGameServiceProvider), same(save));
      container.dispose();
    });
  });
}
