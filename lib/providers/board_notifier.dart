import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/board_state.dart';

final boardProvider = NotifierProvider.autoDispose(
  BoardNotifier.new,
  name: 'boardProvider',
);

class BoardNotifier extends Notifier<BoardState> {
  @override
  BoardState build() => const BoardState();

  void selectCell(int index) {
    state = state.copyWith(
      selectedCell: state.selectedCell == index ? null : index,
    );
  }

  void selectDigit(int digit) {
    state = state.copyWith(
      selectedDigit: state.selectedDigit == digit ? null : digit,
    );
  }

  void toggleInputMode() {
    final currentState = state;
    state = state.copyWith(
      inputMode: currentState.inputMode == .number ? .pencil : .number,
      selectedCell: currentState.selectedCell,
      selectedDigit: currentState.selectedDigit,
    );
  }

  void setErrorCells(Set<int> errorCells) {
    final currentState = state;
    state = state.copyWith(
      errorCells: errorCells,
      selectedCell: currentState.selectedCell,
      selectedDigit: currentState.selectedDigit,
    );
  }

  void removeErrorCell(int errorCell) {
    final currentState = state;
    final errorCells = Set<int>.from(currentState.errorCells)
      ..remove(errorCell);
    state = state.copyWith(
      errorCells: errorCells,
      selectedCell: currentState.selectedCell,
      selectedDigit: currentState.selectedDigit,
    );
  }

  void reset() {
    state = const BoardState();
  }
}
