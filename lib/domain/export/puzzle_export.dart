import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_state.dart';

enum ExportContent {
  givens('Puzzle', 'Just the starting digits.'),
  progress('Progress', 'Starting digits plus everything you placed.');

  new(this.label, this.description);
  final String label;
  final String description;
}

enum ExportFormat {
  line('Digits', 'One line, dots for empty cells. Most apps import this.'),
  grid('Grid', 'Readable 9x9 text grid.'),
  pencilmarks('Pencilmarks', 'Readable 9x9 grid with every candidate.');

  new(this.label, this.description);
  final String label;
  final String description;
}

class PuzzleExport {
  const new({required this.values, required this.givens, required this.notes});

  factory fromState(GameState state) => PuzzleExport(
    values: state.grid.values,
    givens: state.puzzle.given.values,
    notes: state.notes,
  );

  final List<int> values;
  final List<int> givens;
  final List<Set<int>> notes;

  List<int> digitsFor(ExportContent content) =>
      content == ExportContent.givens ? givens : values;

  /// Candidates for the pencilmark grid. Your own notes are used where you made
  /// some, but only for the current position; a note that a later placement has
  /// ruled out is dropped, so the exported position is always valid.
  List<Set<int>> _candidates(List<int> digits, {required bool withNotes}) {
    final possible = buildCandidates(digits);
    if (!withNotes) return possible;
    return [
      for (var i = 0; i < 81; i++)
        if (digits[i] == 0 && notes[i].isNotEmpty)
          _cleanNotes(notes[i], possible[i])
        else
          possible[i],
    ];
  }

  static Set<int> _cleanNotes(Set<int> notes, Set<int> possible) {
    final valid = notes.intersection(possible);
    return valid.isEmpty ? possible : valid;
  }

  String render({
    required ExportContent content,
    required ExportFormat format,
    bool withPrompt = false,
  }) {
    final digits = digitsFor(content);
    final body = switch (format) {
      .line => toLine(digits),
      .grid => toGrid(digits),
      .pencilmarks => toPencilmarks(
        digits,
        _candidates(digits, withNotes: content == .progress),
      ),
    };
    if (!withPrompt) return body;
    return _prompt(content: content, format: format, body: body);
  }

  static String toLine(List<int> digits) =>
      digits.map((v) => v == 0 ? '.' : '$v').join();

  static String toGrid(List<int> digits) {
    final buffer = StringBuffer();
    for (var r = 0; r < 9; r++) {
      if (r == 3 || r == 6) buffer.writeln('------+-------+------');
      final row = <String>[];
      for (var c = 0; c < 9; c++) {
        if (c == 3 || c == 6) row.add('|');
        final v = digits[r * 9 + c];
        row.add(v == 0 ? '.' : '$v');
      }
      buffer.writeln(row.join(' '));
    }
    return buffer.toString().trimRight();
  }

  /// Solved cells show their digit, open cells show all candidates, with
  /// columns padded to equal width.
  static String toPencilmarks(List<int> digits, List<Set<int>> candidates) {
    String cellText(int i) {
      if (digits[i] != 0) return '${digits[i]}';
      final sorted = candidates[i].toList()..sort();
      return sorted.isEmpty ? '.' : sorted.join();
    }

    final widths = List<int>.filled(9, 1);
    for (var c = 0; c < 9; c++) {
      for (var r = 0; r < 9; r++) {
        final len = cellText(r * 9 + c).length;
        if (len > widths[c]) widths[c] = len;
      }
    }

    String separator(String left, String mid, String right) {
      final stacks = [
        for (var s = 0; s < 3; s++)
          '-' * (widths[s * 3] + widths[s * 3 + 1] + widths[s * 3 + 2] + 4),
      ];
      return '$left${stacks.join(mid)}$right';
    }

    final buffer = StringBuffer()..writeln(separator('.', '.', '.'));
    for (var r = 0; r < 9; r++) {
      if (r == 3 || r == 6) buffer.writeln(separator(':', '+', ':'));
      final line = StringBuffer('|');
      for (var c = 0; c < 9; c++) {
        line.write(' ${cellText(r * 9 + c).padRight(widths[c])}');
        if (c % 3 == 2) line.write(' |');
      }
      buffer.writeln(line);
    }
    buffer.write(separator("'", '.', "'"));
    return buffer.toString();
  }

  String _prompt({
    required ExportContent content,
    required ExportFormat format,
    required String body,
  }) {
    final notation = switch (format) {
      .line => 'Format: 81 characters, row by row, "." is an empty cell.',
      .grid => 'Format: 9x9 grid, "." is an empty cell.',
      .pencilmarks =>
        'Format: pencilmark grid, multi-digit entries are candidates.',
    };

    if (!digitsFor(content).contains(0)) {
      return [
        'Here is a full 9x9 Sudoku board. '
            'Please check that it is a valid solution.',
        '',
        notation,
        '',
        body,
      ].join('\n');
    }

    final state = switch (content) {
      .givens => 'Here is the starting position.',
      .progress => 'Here is my current position (starting digits plus my own).',
    };

    return [
      'I am solving a classic 9x9 Sudoku and I am stuck. '
          'Please do not give me the solution.',
      '',
      'Find the next logical step from this exact position. '
          'Start with a small nudge: name the technique and the area to look '
          'at. Only explain the full step (cells, digits, eliminations) if I '
          'ask for it. Use R1C1 notation (row 1 to 9 from top, column 1 to 9 '
          'from left).',
      '',
      state,
      notation,
      '',
      body,
    ].join('\n');
  }
}
