import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/services/puzzle_import_service.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

import '../../helpers/puzzle_strings.dart';

void main() {
  group('PuzzleImportService', () {
    test(
      'loadPuzzleIntoGame returns GameState with computed difficulty',
      () async {
        final service = PuzzleImportService();
        final result = await service.loadPuzzleIntoGame(TestPuzzles.valid);
        expect(result, isA<GameState>());
        expect(result.difficulty, equals(Difficulty.easy));
      },
    );

    test('importPuzzle parses raw input then loads it', () async {
      final service = PuzzleImportService();
      final result = await service.importPuzzle(TestPuzzles.valid9Line);
      expect(result, isA<GameState>());
      expect(result.difficulty, equals(Difficulty.easy));
    });

    test('importPuzzle throws when raw input is not 81 digits', () async {
      final service = PuzzleImportService();
      expect(
        () => service.importPuzzle(TestPuzzles.tooShort),
        throwsA(isA<FormatException>()),
      );
    });

    test('sharePuzzle does not throw', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final service = PuzzleImportService();
      final state = GameState.newGame(
        puzzle: Puzzle(
          given: SudokuGrid(values: List.filled(81, 0)),
          solution: SudokuGrid(values: List.filled(81, 0)),
        ),
        difficulty: Difficulty.easy,
      );
      await service.sharePuzzle(state);
    });

    test('loadPuzzleIntoGame throws for puzzle with no solution', () async {
      final service = PuzzleImportService();
      expect(
        () => service.loadPuzzleIntoGame(TestPuzzles.rowConflict),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'loadPuzzleIntoGame throws for puzzle with multiple solutions',
      () async {
        final service = PuzzleImportService();
        expect(
          () => service.loadPuzzleIntoGame(TestPuzzles.empty),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
