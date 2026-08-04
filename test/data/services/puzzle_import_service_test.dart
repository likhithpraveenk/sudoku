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
  });
}
