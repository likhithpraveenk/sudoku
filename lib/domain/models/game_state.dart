import 'package:sudoku/domain/models/board.dart';
import 'package:sudoku/domain/models/cell.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/domain/models/puzzle.dart';

class GameState {
  final Puzzle puzzle;
  final Difficulty difficulty;
  final Board board;
  final List<Set<int>> notes;
  final List<GameAction> history;
  final Set<Cell> revealedCells;
  final Set<Cell> errorCells;
  final int mistakeCount;
  final bool isSolved;
  final Duration elapsed;
  final Cell? selectedCell;
  final InputMode inputMode;

  const GameState({
    required this.puzzle,
    required this.difficulty,
    required this.board,
    required this.notes,
    required this.history,
    this.revealedCells = const {},
    this.errorCells = const {},
    this.mistakeCount = 0,
    this.isSolved = false,
    this.elapsed = Duration.zero,
    this.selectedCell,
    this.inputMode = .digit,
  }) : assert(notes.length == 81);

  factory GameState.newGame({
    required Puzzle puzzle,
    required Difficulty difficulty,
  }) => GameState(
    puzzle: puzzle,
    difficulty: difficulty,
    board: puzzle.board,
    notes: List.generate(81, (_) => {}),
    history: const [],
  );

  GameState copyWith({
    Puzzle? puzzle,
    Difficulty? difficulty,
    Board? board,
    List<Set<int>>? notes,
    List<GameAction>? history,
    Set<Cell>? revealedCells,
    Set<Cell>? errorCells,
    int? mistakeCount,
    bool? isSolved,
    Duration? elapsed,
    Cell? selectedCell,
    bool clearSelectedCell = false,
    InputMode? inputMode,
  }) => GameState(
    puzzle: puzzle ?? this.puzzle,
    difficulty: difficulty ?? this.difficulty,
    board: board ?? this.board,
    notes: notes ?? this.notes,
    history: history ?? this.history,
    revealedCells: revealedCells ?? this.revealedCells,
    errorCells: errorCells ?? this.errorCells,
    mistakeCount: mistakeCount ?? this.mistakeCount,
    isSolved: isSolved ?? this.isSolved,
    elapsed: elapsed ?? this.elapsed,
    selectedCell: clearSelectedCell ? null : selectedCell ?? this.selectedCell,
    inputMode: inputMode ?? this.inputMode,
  );
}
