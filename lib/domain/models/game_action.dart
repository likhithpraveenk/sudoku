sealed class GameAction {
  const GameAction();
}

class DigitAction extends GameAction {
  const DigitAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
    required this.newValue,
  });

  final int cellIndex;

  final int previousValue;

  final Map<int, Set<int>> previousNotes;

  final int newValue;
}

class PencilAction extends GameAction {
  const PencilAction({
    required this.cellIndex,
    required this.previousNotes,
    required this.newNotes,
  });

  final int cellIndex;

  final Set<int> previousNotes;

  final Set<int> newNotes;
}

class EraseAction extends GameAction {
  const EraseAction({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
  });

  final int cellIndex;

  final int previousValue;

  final Set<int> previousNotes;
}

class AutoNotesAction extends GameAction {
  const AutoNotesAction({required this.previousNotes});

  final List<Set<int>> previousNotes;
}
