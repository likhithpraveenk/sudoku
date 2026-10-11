class PuzzleParser {
  const new();

  static final _gap = RegExp('[.xX_]');
  static final _nonDigit = RegExp('[^0-9]');

  String parse(String raw) {
    final puzzle = raw.replaceAll(_gap, '0').replaceAll(_nonDigit, '');

    if (puzzle.length != 81) {
      throw FormatException('Found ${puzzle.length} characters, expected 81.');
    }
    return puzzle;
  }

  bool validate(String puzzle) {
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
}
