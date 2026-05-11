import 'package:sudoku/domain/models/cell.dart';

sealed class GameAction {
  const GameAction();
}

class DigitAction extends GameAction {
  final Cell cell;
  final int previousValue;
  final int newValue;
  const DigitAction({
    required this.cell,
    required this.previousValue,
    required this.newValue,
  });
}

class PencilAction extends GameAction {
  final Cell cell;
  final Set<int> previousNotes;
  final Set<int> newNotes;
  const PencilAction({
    required this.cell,
    required this.previousNotes,
    required this.newNotes,
  });
}

class EraseAction extends GameAction {
  final Cell cell;
  final int previousValue;
  final Set<int> previousNotes;
  const EraseAction({
    required this.cell,
    required this.previousValue,
    required this.previousNotes,
  });
}

class AutoNotesAction extends GameAction {
  final List<Set<int>> previousNotes;
  const AutoNotesAction({required this.previousNotes});
}
