/// Represents an undoable game action performed by the player during gameplay.
sealed class GameAction {
  /// Base constructor for all game actions.
  const GameAction();
}

/// Represents an action where a direct digit value was input onto the board.
class DigitAction extends GameAction {
  /// Creates a digit placement action.
  const DigitAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
    required this.newValue,
  });

  /// The index of the cell that was updated.
  final int cellIndex;

  /// The value of the cell prior to this action.
  final int previousValue;

  /// The pencil notes of affected cells prior to this action (for auto-cleanup
  /// tracking).
  final Map<int, Set<int>> previousNotes;

  /// The new digit value placed in the cell.
  final int newValue;
}

/// Represents an action where a pencil note candidate was toggled in a cell.
class PencilAction extends GameAction {
  /// Creates a pencil note toggle action.
  const PencilAction({
    required this.cellIndex,
    required this.previousNotes,
    required this.newNotes,
  });

  /// The index of the cell whose notes were modified.
  final int cellIndex;

  /// The set of pencil notes prior to this action.
  final Set<int> previousNotes;

  /// The set of pencil notes after this action.
  final Set<int> newNotes;
}

/// Represents an action where a cell's value or notes were erased.
class EraseAction extends GameAction {
  /// Creates an erase action.
  const EraseAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
  });

  /// The index of the cell that was cleared.
  final int cellIndex;

  /// The digit value prior to being erased.
  final int previousValue;

  /// The pencil notes prior to being erased.
  final Set<int> previousNotes;
}

/// Represents an action where the automatic pencil notes helper was run.
class AutoNotesAction extends GameAction {
  /// Creates an auto-notes generation action.
  const AutoNotesAction({required this.previousNotes});

  /// The state of all pencil notes across the board prior to auto-filling.
  final List<Set<int>> previousNotes;
}
