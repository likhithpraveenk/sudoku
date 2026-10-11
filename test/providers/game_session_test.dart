import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/services/save_game_service.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/providers/game_session.dart';

import '../helpers/fake_services.dart';
import '../helpers/sudoku_grids.dart';

GameState _game({bool complete = false}) {
  return GameState.newGame(
    puzzle: Puzzle(
      given: TestGrids.simplePuzzle(),
      solution: TestGrids.simpleSolution(),
    ),
    difficulty: .easy,
  ).copyWith(puzzleComplete: complete);
}

class Harness {
  Harness(this.saves) {
    session = GameSession(
      saveGameService: saves,
      onRecord: records.add,
      onPersistStat: (_) async {},
      onTick: () => ticks++,
    );
  }

  final SaveGameService saves;
  final List<StatRecord> records = [];
  int ticks = 0;
  late final GameSession session;

  GameState game({bool complete = false}) => _game(complete: complete);
}

class _GatedSaveGameService implements SaveGameService {
  final Completer<void> gate = Completer<void>();
  final List<GameState> saved = [];
  final List<Difficulty> deleted = [];

  @override
  Future<void> save(GameState state) async {
    await gate.future;
    saved.add(state);
  }

  @override
  GameState? load(Difficulty difficulty) => null;

  @override
  Future<void> delete(Difficulty difficulty) async {
    deleted.add(difficulty);
  }
}

void main() {
  group('onMutated', () {
    test('saves the mutated state', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);
      final state = h.game();

      await h.session.onMutated(state);

      expect(saves.saveCalls, 1);
      expect(saves.savedFor(.easy), state);
    });

    test('takes the completion path instead of saving', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);

      await h.session.onMutated(h.game(complete: true));

      expect(saves.saveCalls, 0);
      expect(saves.deleteCalls, 1);
      expect(saves.deletedDifficulties, [Difficulty.easy]);
      expect(h.records, hasLength(1));
      expect(h.records.single.difficulty, Difficulty.easy);
    });

    test('records a stat only once when completion repeats', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);
      final complete = h.game(complete: true);

      await h.session.onMutated(complete);
      await h.session.onMutated(complete);

      expect(h.records, hasLength(1));
      expect(saves.deleteCalls, 1);
    });

    test('saves again once the game resumes after completion', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);
      await h.session.onMutated(h.game(complete: true));
      final resumed = h.game();

      await h.session.onMutated(resumed);

      expect(saves.saveCalls, 1);
      expect(saves.savedFor(.easy), resumed);
    });
  });

  group('serialization', () {
    test('a save waits for the one before it', () async {
      final service = _GatedSaveGameService();
      final h = Harness(service);

      final first = h.game();
      final second = h.game().copyWith(elapsed: const Duration(seconds: 5));
      final firstDone = h.session.onMutated(first);
      final secondDone = h.session.onMutated(second);

      await Future<void>.delayed(Duration.zero);
      expect(service.saved, isEmpty, reason: 'the gate is still closed');

      service.gate.complete();
      await Future.wait([firstDone, secondDone]);

      expect(service.saved, [first, second]);
    });
  });

  group('timer', () {
    test('the clock ticks while it runs and stops when paused', () {
      fakeAsync((async) {
        final h = Harness(FakeSaveGameService());

        h.session.startTimer();
        async.elapse(kTick * 2);
        final running = h.ticks;
        h.session.pauseTimer();

        expect(running, greaterThan(0));
        expect(h.ticks, running);
      });
    });

    test('startTimer restarts a paused clock', () {
      fakeAsync((async) {
        final h = Harness(FakeSaveGameService());

        h.session.startTimer();
        async.elapse(kTick * 2);
        final running = h.ticks;

        h.session.startTimer();
        async.elapse(kTick * 2);

        expect(running, greaterThan(0));
        expect(h.ticks, greaterThan(running));
      });
    });

    test('completing the puzzle stops the clock', () {
      fakeAsync((async) {
        final h = Harness(FakeSaveGameService());

        h.session.startTimer();
        async.elapse(kTick * 2);
        final running = h.ticks;
        expect(running, greaterThan(0));

        h.session.onMutated(h.game(complete: true));
        async.elapse(kTick * 2);

        expect(h.ticks, running);
      });
    });

    test('the clock resumes when the game does', () {
      fakeAsync((async) {
        final h = Harness(FakeSaveGameService());

        h.session.onMutated(h.game(complete: true));
        h.session.startTimer();
        async.elapse(kTick * 2);
        expect(h.ticks, 0);

        h.session.onMutated(h.game());
        h.session.startTimer();
        async.elapse(kTick * 2);

        expect(h.ticks, greaterThan(0));
      });
    });
  });

  group('dispose', () {
    test('persists the most recent state', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);
      final first = h.game();
      final second = h.game().copyWith(elapsed: const Duration(seconds: 5));

      await h.session.onMutated(first);
      await h.session.onMutated(second);
      await h.session.dispose();

      expect(saves.saveCalls, 3);
      expect(saves.savedFor(.easy), second);
    });

    test('deletes a completed game rather than saving it', () async {
      final saves = FakeSaveGameService();
      final h = Harness(saves);

      await h.session.onMutated(h.game(complete: true));
      await h.session.dispose();

      expect(saves.saveCalls, 0);
      expect(saves.deleteCalls, greaterThanOrEqualTo(1));
    });

    test('stops the clock', () {
      fakeAsync((async) {
        final h = Harness(FakeSaveGameService());

        h.session.startTimer();
        async.elapse(kTick * 2);
        final running = h.ticks;
        expect(running, greaterThan(0));

        h.session.dispose();
        async.elapse(kTick * 2);

        expect(h.ticks, running);
      });
    });
  });
}
