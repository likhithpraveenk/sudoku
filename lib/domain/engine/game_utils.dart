import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_state.dart';

Set<int> peers(int index) => peersOf(index);

bool isConflict(GameState state, int index, int value) {
  if (value == 0) return false;
  return peersOf(index).any((p) => state.grid.valueAt(p) == value);
}

bool isSolved(GameState state) {
  for (var i = 0; i < 81; i++) {
    if (state.grid.valueAt(i) != state.puzzle.solution.valueAt(i)) return false;
  }
  return true;
}

bool isGiven(GameState state, int index) => state.puzzle.isGivenAt(index);

int getValue(GameState state, int index) => state.grid.valueAt(index);

Set<int> getNotes(GameState state, int index) => Set.from(state.notes[index]);

bool hasNotes(GameState state, int index) => state.notes[index].isNotEmpty;

String parsePuzzleInput(String raw) {
  final puzzle = raw
      .replaceAll(RegExp(r'[.xX_]'), '0')
      .replaceAll(RegExp(r'[^0-9]'), '');

  if (puzzle.length != 81) {
    throw FormatException('Found ${puzzle.length} characters, expected 81.');
  }
  return puzzle;
}

bool validatePuzzleString(String puzzle) {
  if (puzzle.length != 81) return false;

  for (var i = 0; i < 81; i++) {
    final c = puzzle[i];
    if (c.codeUnitAt(0) < 48 || c.codeUnitAt(0) > 57) return false;
  }

  bool noConflicts(Iterable<int> indices) {
    final seen = <String>{};
    for (final i in indices) {
      if (puzzle[i] == '0') continue;
      if (!seen.add(puzzle[i])) return false;
    }
    return true;
  }

  for (var r = 0; r < 9; r++) {
    if (!noConflicts(List.generate(9, (c) => r * 9 + c))) return false;
  }
  for (var c = 0; c < 9; c++) {
    if (!noConflicts(List.generate(9, (r) => r * 9 + c))) return false;
  }
  for (var br = 0; br < 9; br += 3) {
    for (var bc = 0; bc < 9; bc += 3) {
      final idx = [
        for (var r = 0; r < 3; r++)
          for (var c = 0; c < 3; c++) (br + r) * 9 + (bc + c),
      ];
      if (!noConflicts(idx)) return false;
    }
  }
  return true;
}
