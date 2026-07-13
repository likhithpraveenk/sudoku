import 'package:sudoku/domain/engine/game_utils.dart';
import 'package:sudoku/domain/engine/grid_utils.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_state.dart';

class GameEngine {
  GameEngine(this._initialState) {
    _state = _initialState;
  }

  final GameState _initialState;
  late GameState _state;

  GameState get currentState => _state;

  bool get canUndo => _state.history.isNotEmpty;

  void tick(Duration duration) {
    _state = _state.copyWith(elapsed: _state.elapsed + duration);
  }

  void inputDigit(int cellIndex, int digit, {bool autoRemoveNotes = false}) {
    if (isGiven(_state, cellIndex)) return;

    final currentValue = getValue(_state, cellIndex);
    if (currentValue == digit) {
      erase(cellIndex);
      return;
    }

    if (digit == 0) {
      erase(cellIndex);
      return;
    }

    final previousNotes = <int, Set<int>>{};
    previousNotes[cellIndex] = Set<int>.from(_state.notes[cellIndex]);

    final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));

    for (final peerIndex in peersOf(cellIndex)) {
      previousNotes[peerIndex] = Set<int>.from(_state.notes[peerIndex]);
      if (autoRemoveNotes) {
        newNotes[peerIndex].remove(digit);
      }
    }

    newNotes[cellIndex].clear();

    final action = DigitAction(
      cellIndex: cellIndex,
      previousValue: currentValue,
      newValue: digit,
      previousNotes: previousNotes,
    );

    final grid = _state.grid.clone()..setValue(cellIndex, digit);
    _state = _state.copyWith(
      grid: grid,
      notes: newNotes,
      history: [..._state.history, action],
    );

    if (isSolved(_state)) {
      _state = _state.copyWith(puzzleComplete: true);
    }
  }

  void toggleNote(int cellIndex, int digit) {
    if (isGiven(_state, cellIndex)) return;

    final previousValue = getValue(_state, cellIndex);
    final grid = _state.grid.clone()..clearValue(cellIndex);

    final current = Set<int>.from(_state.notes[cellIndex]);
    final updated = current.contains(digit)
        ? (current..remove(digit))
        : (current..add(digit));

    final action = PencilAction(
      cellIndex: cellIndex,
      previousNotes: Set<int>.from(_state.notes[cellIndex]),
      newNotes: Set<int>.from(updated),
      previousValue: previousValue,
    );

    final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));
    newNotes[cellIndex] = updated;

    _state = _state.copyWith(
      grid: grid,
      notes: newNotes,
      history: [..._state.history, action],
    );
  }

  void erase(int cellIndex) {
    if (isGiven(_state, cellIndex)) return;

    final previousValue = getValue(_state, cellIndex);
    final previousNotes = Set<int>.from(_state.notes[cellIndex]);
    if (previousValue == 0 && previousNotes.isEmpty) return;

    final action = EraseAction(
      cellIndex: cellIndex,
      previousValue: previousValue,
      previousNotes: previousNotes,
    );

    final grid = _state.grid.clone()..clearValue(cellIndex);
    final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));
    newNotes[cellIndex] = {};

    _state = _state.copyWith(
      grid: grid,
      notes: newNotes,
      history: [..._state.history, action],
    );
  }

  void undo() {
    if (!canUndo) return;
    final action = _state.history.last;
    final trimmed = _state.history.sublist(0, _state.history.length - 1);

    switch (action) {
      case DigitAction():
        final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));
        action.previousNotes.forEach((i, notes) {
          newNotes[i] = Set<int>.from(notes);
        });
        final grid = _state.grid.clone()
          ..setValue(action.cellIndex, action.previousValue);
        _state = _state.copyWith(grid: grid, notes: newNotes, history: trimmed);
        break;
      case PencilAction():
        final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));
        newNotes[action.cellIndex] = Set<int>.from(action.previousNotes);
        final grid = _state.grid.clone()
          ..setValue(action.cellIndex, action.previousValue);
        _state = _state.copyWith(grid: grid, notes: newNotes, history: trimmed);
        break;
      case EraseAction():
        final newNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));
        newNotes[action.cellIndex] = Set<int>.from(action.previousNotes);
        final grid = _state.grid.clone()
          ..setValue(action.cellIndex, action.previousValue);
        _state = _state.copyWith(grid: grid, notes: newNotes, history: trimmed);
        break;
      case AutoNotesAction():
        _state = _state.copyWith(
          notes: action.previousNotes.map(Set<int>.from).toList(),
          history: trimmed,
        );
        break;
    }
  }

  void revealHint({bool autoRemoveNotes = false}) {
    final result = firstEmptyOrWrong(
      _state.grid.values,
      _state.puzzle.solution.values,
    );
    if (result == null) return;

    _state = _state.copyWith(assists: _state.assists.copyWith(hints: true));
    inputDigit(result.index, result.correct, autoRemoveNotes: autoRemoveNotes);
  }

  Set<int> findErrors() {
    _state = _state.copyWith(
      assists: _state.assists.copyWith(validation: true),
    );
    final errors = <int>{};
    for (var i = 0; i < 81; i++) {
      if (_state.grid.valueAt(i) != 0 &&
          _state.grid.valueAt(i) != _state.puzzle.solution.valueAt(i)) {
        errors.add(i);
      }
    }
    return errors;
  }

  void autoFillNotes() {
    final prevNotes = List<Set<int>>.from(_state.notes.map(Set<int>.from));

    final newNotes = List<Set<int>>.generate(81, (i) {
      if (_state.grid.valueAt(i) != 0 || _state.puzzle.isGivenAt(i)) {
        return <int>{};
      }

      final used = <int>{};
      for (final peer in peersOf(i)) {
        final v = _state.grid.valueAt(peer);
        if (v != 0) used.add(v);
      }

      return {1, 2, 3, 4, 5, 6, 7, 8, 9}..removeAll(used);
    });
    _state = _state.copyWith(assists: _state.assists.copyWith(autoNotes: true));
    final action = AutoNotesAction(previousNotes: prevNotes);
    _state = _state.copyWith(
      notes: newNotes,
      history: [..._state.history, action],
    );
  }

  void restart() {
    _state = _initialState.copyWith(elapsed: _state.elapsed);
  }
}
