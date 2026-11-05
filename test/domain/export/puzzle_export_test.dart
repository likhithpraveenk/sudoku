import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/export/puzzle_export.dart';

void main() {
  final givens = List<int>.filled(81, 0)
    ..[0] = 5
    ..[80] = 9;
  final values = List<int>.from(givens)..[1] = 3;
  final notes = List<Set<int>>.generate(81, (_) => <int>{})..[2] = {1, 2};
  final export = PuzzleExport(values: values, givens: givens, notes: notes);

  group('PuzzleExport', () {
    test('line uses dots and has 81 characters', () {
      final text = export.render(content: .givens, format: .line);
      expect(text.length, 81);
      expect(text[0], '5');
      expect(text[1], '.');
      expect(text[80], '9');
    });

    test('progress includes the digits the player placed', () {
      final text = export.render(content: .progress, format: .line);
      expect(text.substring(0, 3), '53.');
    });

    test('grid has 11 lines', () {
      final text = export.render(content: .givens, format: .grid);
      expect(text.split('\n').length, 11);
    });

    test('grid rows all have the same width', () {
      final text = export.render(content: .givens, format: .grid);
      final rows = text
          .split('\n')
          .where((line) => !line.contains('+'))
          .toList();
      expect(rows.length, 9);
      expect(rows.map((row) => row.length).toSet().length, 1);
    });

    test('pencilmarks use the player notes where a cell has some', () {
      final text = export.render(content: .progress, format: .pencilmarks);
      final lines = text.split('\n');
      expect(lines.length, 13);
      expect(lines[1], contains(' 12 '));
    });

    test('pencilmarks fall back to every possible digit without notes', () {
      final text = export.render(content: .progress, format: .pencilmarks);
      // R1C4 has no notes. It sees the 5 and the 3 in row 1, so it keeps the
      // other seven digits.
      expect(text.split('\n')[1], contains('1246789'));
    });

    test('a note that a placement rules out is dropped', () {
      // The player noted 3 in R1C3, then placed 3 in R1C2. The stale note must
      // not survive into the exported candidates.
      final stale = List<Set<int>>.generate(81, (_) => <int>{})..[2] = {1, 3};
      final text = PuzzleExport(
        values: values,
        givens: givens,
        notes: stale,
      ).render(content: .progress, format: .pencilmarks);
      expect(text.split('\n')[1], isNot(contains('13')));
      expect(text.split('\n')[1], contains(' 1 '));
    });

    test('the line format for progress is 81 characters', () {
      expect(export.render(content: .progress, format: .line).length, 81);
    });

    test('puzzle pencilmarks ignore the notes, since they are not this board', () {
      final text = export.render(content: .givens, format: .pencilmarks);
      // R1C3 has the note {1, 2}, but the starting puzzle does not include the
      // player's own 3, so the grid shows the givens' candidates instead.
      expect(text.split('\n')[1], isNot(contains(' 12 ')));
    });

    test('a placed digit shows its value, not candidates', () {
      final text = export.render(content: .progress, format: .pencilmarks);
      expect(text.split('\n')[1], matches(RegExp(r'^\| 5 +3 ')));
    });

    test('a completed board gets a completion prompt', () {
      final solved = List<int>.generate(81, (i) => ((i ~/ 9 + i % 9) % 9) + 1);
      final done = PuzzleExport(
        values: solved,
        givens: solved,
        notes: List<Set<int>>.generate(81, (_) => <int>{}),
      );
      final text = done.render(
        content: .progress,
        format: .line,
        withPrompt: true,
      );
      expect(text, startsWith('Here is a full'));
      expect(text, isNot(contains('stuck')));
      expect(text, contains(solved.join()));
    });

    test('the prompt wraps the board and asks for no solution', () {
      final text = export.render(
        content: .progress,
        format: .line,
        withPrompt: true,
      );
      expect(text, contains('do not give me the solution'));
      expect(text.trim().split('\n').last.length, 81);
    });
  });
}
