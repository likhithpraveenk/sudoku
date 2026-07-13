import 'package:sudoku/domain/engine/grid_utils.dart';

class SudokuGrid {
  SudokuGrid({List<int>? values, List<int>? candidates})
    : _values = values ?? List.filled(81, 0),
      _candidates = candidates ?? List.filled(81, 0x1FF) {
    if (candidates == null) {
      for (var i = 0; i < 81; i++) {
        if (_values[i] != 0) {
          _candidates[i] = 0;
          for (final peer in kGridPeers[i]) {
            _removeCandidate(peer, _values[i]);
          }
        }
      }
    }
  }

  factory SudokuGrid.fromString(String s) {
    assert(s.length == 81, 'String length must be 81');
    final values = s.codeUnits.map((c) => c - 48).toList();
    return SudokuGrid(values: values);
  }

  factory SudokuGrid.fromRows(List<List<int>> rows) {
    assert(rows.length == 9, 'Rows must have length 9');
    final values = <int>[];
    for (final row in rows) {
      assert(row.length == 9, 'Each row must have length 9');
      values.addAll(row);
    }
    return SudokuGrid(values: values);
  }
  final List<int> _values;
  final List<int> _candidates;

  int valueAt(int index) => _values[index];

  int candidateMaskAt(int index) => _candidates[index];

  List<int> get values => List<int>.from(_values);

  List<int> getCandidates(int index) {
    if (_values[index] != 0) return [];
    final result = <int>[];
    for (var d = 1; d <= 9; d++) {
      if (isCandidate(index, d)) result.add(d);
    }
    return result;
  }

  bool isCandidate(int index, int digit) {
    final bit = 1 << (digit - 1);
    return (_candidates[index] & bit) != 0;
  }

  void clearValue(int index) {
    _values[index] = 0;
  }

  void setValue(int index, int value) {
    assert(value >= 0 && value <= 9, 'Value must be between 0 and 9');
    if (value == 0) {
      clearValue(index);
      return;
    }
    _values[index] = value;
    _candidates[index] = 0;
    for (final peer in kGridPeers[index]) {
      _removeCandidate(peer, value);
    }
  }

  void removeCandidate(int index, int digit) {
    assert(_values[index] == 0, 'Cannot remove candidate from filled cell');
    _removeCandidate(index, digit);
  }

  void addCandidate(int index, int digit) {
    assert(_values[index] == 0, 'Cannot add candidate to filled cell');
    assert(digit >= 1 && digit <= 9, 'Digit must be between 1 and 9');
    final bit = 1 << (digit - 1);
    _candidates[index] |= bit;
  }

  void _removeCandidate(int index, int digit) {
    final bit = 1 << (digit - 1);
    _candidates[index] &= ~bit;
  }

  SudokuGrid clone() {
    return SudokuGrid(
      values: List<int>.from(_values),
      candidates: List<int>.from(_candidates),
    );
  }

  bool isSolved() => !_values.contains(0);

  String toString81() => _values.map((v) => v.toString()).join();

  Map<int, int> get digitCounts {
    final counts = <int, int>{};

    for (final value in _values) {
      if (value == 0) continue;

      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var i = 0; i < 81; i++) {
      if (i % 9 == 0 && i != 0) {
        buffer.writeln();
        if (i == 27 || i == 54) {
          buffer.writeln('------+-------+------');
        }
      }
      if (i % 3 == 0 && i % 9 != 0) {
        buffer.write('| ');
      }
      final value = _values[i];
      buffer.write(value == 0 ? '. ' : '$value ');
    }
    return buffer.toString();
  }
}
