import 'package:sudoku/domain/engine/grid_utils.dart';

/// Represents a high-performance, mutable 9x9 Sudoku board grid structure.
///
/// This class stores cell digit values in a simple flat list [_values] (length
/// 81) and tracks candidate masks in [_candidates] (length 81). Candidate masks
/// are stored as bitfields where the 9 least-significant bits represent digits
/// 1 to 9 (e.g. 0x1FF = all 9 candidates). Setting a cell value automatically
/// updates the board configuration and eliminates the placed digit from the
/// candidate lists of all its peer cells.
class SudokuGrid {
  /// Creates a new Sudoku grid instance, optionally initializing it with values
  /// or candidate masks.
  SudokuGrid({List<int>? values, List<int>? candidates})
    : _values = values ?? List.filled(81, 0),
      _candidates = candidates ?? List.filled(81, 0x1FF) {
    for (var i = 0; i < 81; i++) {
      if (_values[i] != 0) {
        _candidates[i] = 0;
        for (final peer in kGridPeers[i]) {
          _removeCandidate(peer, _values[i]);
        }
      }
    }
  }

  /// Creates a [SudokuGrid] instance from an 81-character flat string
  /// representation of digits.
  factory SudokuGrid.fromString(String s) {
    assert(s.length == 81, 'String length must be 81');
    final values = s.codeUnits.map((c) => c - 48).toList();
    return SudokuGrid(values: values);
  }

  /// Creates a [SudokuGrid] instance from a list of nine rows, each containing
  /// nine cell values.
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

  /// Returns the digit value stored at the given cell [index].
  int valueAt(int index) => _values[index];

  /// Returns the raw bitmask representation of the active candidates at the
  /// given cell [index].
  int candidateMaskAt(int index) => _candidates[index];

  /// Returns a copy of the raw 81-character flat list of cell values.
  List<int> get values => List<int>.from(_values);

  /// Computes and returns the list of active candidate digits for a cell
  /// [index].
  List<int> getCandidates(int index) {
    if (_values[index] != 0) return [];
    final result = <int>[];
    for (var d = 1; d <= 9; d++) {
      if (isCandidate(index, d)) result.add(d);
    }
    return result;
  }

  /// Returns true if the given [digit] is currently a valid candidate at
  /// [index].
  bool isCandidate(int index, int digit) {
    final bit = 1 << (digit - 1);
    return (_candidates[index] & bit) != 0;
  }

  /// Clears the value stored at [index] by resetting it back to 0.
  void clearValue(int index) {
    _values[index] = 0;
  }

  /// Sets the value of a cell [index] to [value] and updates the candidate list
  /// of all peer cells.
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

  /// Manually removes a [digit] from the candidate list of cell [index].
  void removeCandidate(int index, int digit) {
    assert(_values[index] == 0, 'Cannot remove candidate from filled cell');
    _removeCandidate(index, digit);
  }

  /// Manually adds a [digit] back into the candidate list of cell [index].
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

  /// Returns a deep copy clone of the active grid structure.
  SudokuGrid clone() {
    return SudokuGrid(
      values: List<int>.from(_values),
      candidates: List<int>.from(_candidates),
    );
  }

  /// Returns true if every cell index on the board is filled (non-zero).
  bool isSolved() => !_values.contains(0);

  /// Returns an 81-character flat string representation of the grid.
  String toString81() => _values.map((v) => v.toString()).join();

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var i = 0; i < 81; i++) {
      if (i % 9 == 0 && i != 0) {
        buffer.writeln('------+-------+------');
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
