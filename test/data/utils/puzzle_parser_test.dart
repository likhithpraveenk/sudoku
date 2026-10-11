import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/utils/puzzle_parser.dart';

import '../../helpers/puzzle_strings.dart';

void main() {
  const parser = PuzzleParser();

  group('PuzzleParser.parse', () {
    test('parses raw 81-char string', () {
      final result = parser.parse(TestPuzzles.valid);
      expect(result, TestPuzzles.valid);
    });

    test('parses 9-line grid with newlines', () {
      final result = parser.parse(TestPuzzles.valid9Line);
      expect(result.length, 81);
      expect(result, equals(TestPuzzles.valid));
    });

    test('throws FormatException when character count is wrong', () {
      expect(
        () => parser.parse(TestPuzzles.tooLong),
        throwsA(isA<FormatException>()),
      );
    });

    test('treats . _ x X as blank (0)', () {
      final result = parser.parse(TestPuzzles.validWithSupportedGaps);
      expect(result.length, 81);
      expect(result[2], '0');
      expect(result[3], '0');
      expect(result[5], '0');
      expect(result[6], '0');
    });

    test('ignores letters, punctuation', () {
      const input =
          'abc530070000!@#600195000\n\r\t098000060098000060098000060098000060098000060098000060098000060';
      final result = parser.parse(input);
      expect(result.length, 81);
      expect(result.startsWith('530070000'), isTrue);
    });
  });

  group('PuzzleParser.validate', () {
    test('returns true for a valid puzzle string', () {
      expect(parser.validate(TestPuzzles.valid), isTrue);
    });

    test('returns false for wrong length', () {
      expect(parser.validate(TestPuzzles.tooShort), isFalse);
    });

    test('returns false for invalid characters', () {
      expect(parser.validate(TestPuzzles.invalidChars), isFalse);
    });

    test('returns false for row conflicts', () {
      expect(parser.validate(TestPuzzles.rowConflict), isFalse);
    });
  });
}
