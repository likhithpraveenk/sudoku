import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

abstract class Hint {
  const Hint();

  void apply(SudokuGrid grid);

  String description();

  Difficulty getDifficultyLevel();

  bool isPlacement();
}

class DirectHint extends Hint {
  const DirectHint(this.cellIndex, this.value, this.difficulty);

  final int cellIndex;

  final int value;

  final Difficulty difficulty;

  @override
  void apply(SudokuGrid grid) {
    grid.setValue(cellIndex, value);
  }

  @override
  String description() {
    final row = cellIndex ~/ 9 + 1;
    final col = cellIndex % 9 + 1;
    return 'Place $value at ($row,$col)';
  }

  @override
  Difficulty getDifficultyLevel() => difficulty;

  @override
  bool isPlacement() => true;
}

class IndirectHint extends Hint {
  const IndirectHint(this.cellIndex, this.valuesToRemove, this.difficulty);

  final int cellIndex;

  final List<int> valuesToRemove;

  final Difficulty difficulty;

  @override
  void apply(SudokuGrid grid) {
    for (final value in valuesToRemove) {
      grid.removeCandidate(cellIndex, value);
    }
  }

  @override
  String description() {
    final row = cellIndex ~/ 9 + 1;
    final col = cellIndex % 9 + 1;
    return 'Remove ${valuesToRemove.join(', ')} from candidates at ($row,$col)';
  }

  @override
  Difficulty getDifficultyLevel() => difficulty;

  @override
  bool isPlacement() => false;
}
