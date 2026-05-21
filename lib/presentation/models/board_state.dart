import 'package:sudoku/presentation/shared/input_method.dart';

class BoardState {
  const BoardState({
    this.selectedCell,
    this.selectedDigit,
    this.inputMode = .number,
    this.errorCells = const {},
  });

  final int? selectedCell;
  final int? selectedDigit;
  final InputMode inputMode;
  final Set<int> errorCells;

  BoardState copyWith({
    int? selectedCell,
    int? selectedDigit,
    InputMode? inputMode,
    Set<int>? errorCells,
  }) {
    return BoardState(
      selectedCell: selectedCell,
      selectedDigit: selectedDigit,
      inputMode: inputMode ?? this.inputMode,
      errorCells: errorCells ?? this.errorCells,
    );
  }

  @override
  int get hashCode =>
      Object.hash(selectedCell, selectedDigit, inputMode, errorCells);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardState &&
          selectedCell == other.selectedCell &&
          selectedDigit == other.selectedDigit &&
          inputMode == other.inputMode &&
          errorCells == errorCells;

  @override
  String toString() {
    return '''BoardState:
    selectedCell: $selectedCell
    selectedDigit: $selectedDigit
    inputMode: $inputMode
    errorCells: $errorCells
''';
  }
}
