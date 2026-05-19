import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';

/// Represents the immutable state of an active Sudoku game session.
///
/// This class holds all data related to the active gameplay, including the
/// initial [puzzle], the selected [difficulty], the current board [grid], and
/// the pencil [notes] lists. It also contains session metadata such as selected
/// items, error highlights, statistics, and gameplay duration.
class GameState {
  /// Creates a new game state instance.
  const GameState({
    required this.puzzle,
    required this.difficulty,
    required this.grid,
    required this.notes,
    required this.history,
    this.revealedCells = const {},
    this.errorCells = const {},
    this.mistakeCount = 0,
    this.isSolved = false,
    this.elapsed = Duration.zero,
    this.selectedCell,
    this.selectedDigit,
    this.inputMode = InputMode.digit,
  }) : assert(notes.length == 81, 'Notes list must be of length 81');

  /// Factory method to initialize a new game session state given a [puzzle] and
  /// [difficulty].
  factory GameState.newGame({
    required Puzzle puzzle,
    required Difficulty difficulty,
  }) => GameState(
    puzzle: puzzle,
    difficulty: difficulty,
    grid: puzzle.grid,
    notes: List.generate(81, (_) => {}),
    history: const [],
  );

  /// The initial puzzle template containing the puzzle clues, correct solution,
  /// and given mask.
  final Puzzle puzzle;

  /// The active difficulty level of the puzzle.
  final Difficulty difficulty;

  /// The current state of the 9x9 Sudoku board grid.
  final SudokuGrid grid;

  /// An 81-element list mapping each cell index to its set of pencil notes.
  final List<Set<int>> notes;

  /// The record of undoable game actions performed during the game.
  final List<GameAction> history;

  /// A set of cell indices that were filled automatically using a reveal hint.
  final Set<int> revealedCells;

  /// A set of cell indices currently marked as containing incorrect values.
  final Set<int> errorCells;

  /// The total number of mistakes made during the active session.
  final int mistakeCount;

  /// A boolean flag showing whether the board is completely and correctly
  /// solved.
  final bool isSolved;

  /// The cumulative active time spent solving the puzzle.
  final Duration elapsed;

  /// The index of the currently highlighted cell, if any.
  final int? selectedCell;

  /// The active digit selected globally for digit-first entry, if any.
  final int? selectedDigit;

  /// The current input method mode (direct digits or pencil candidates).
  final InputMode inputMode;

  /// Returns a copy of the game state with updated fields, optionally clearing
  /// selections.
  GameState copyWith({
    Puzzle? puzzle,
    Difficulty? difficulty,
    SudokuGrid? grid,
    List<Set<int>>? notes,
    List<GameAction>? history,
    Set<int>? revealedCells,
    Set<int>? errorCells,
    int? mistakeCount,
    bool? isSolved,
    Duration? elapsed,
    int? selectedCell,
    bool clearSelectedCell = false,
    int? selectedDigit,
    bool clearSelectedDigit = false,
    InputMode? inputMode,
  }) => GameState(
    puzzle: puzzle ?? this.puzzle,
    difficulty: difficulty ?? this.difficulty,
    grid: grid ?? this.grid,
    notes: notes ?? this.notes,
    history: history ?? this.history,
    revealedCells: revealedCells ?? this.revealedCells,
    errorCells: errorCells ?? this.errorCells,
    mistakeCount: mistakeCount ?? this.mistakeCount,
    isSolved: isSolved ?? this.isSolved,
    elapsed: elapsed ?? this.elapsed,
    selectedCell: clearSelectedCell ? null : selectedCell ?? this.selectedCell,
    selectedDigit: clearSelectedDigit
        ? null
        : selectedDigit ?? this.selectedDigit,
    inputMode: inputMode ?? this.inputMode,
  );
}
