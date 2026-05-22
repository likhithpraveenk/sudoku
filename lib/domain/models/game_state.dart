import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_action.dart';
import 'package:sudoku/domain/models/game_assists.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';
import 'package:sudoku/domain/models/utils.dart';

class GameState {
  const GameState({
    required this.puzzle,
    required this.difficulty,
    required this.grid,
    required this.notes,
    required this.history,
    this.puzzleComplete = false,
    this.elapsed = Duration.zero,
    this.assists = const GameAssists(),
  });

  final Puzzle puzzle;
  final Difficulty difficulty;
  final SudokuGrid grid;
  final List<Set<int>> notes;
  final List<GameAction> history;
  final bool puzzleComplete;
  final Duration elapsed;
  final GameAssists assists;

  factory GameState.newGame({
    required Puzzle puzzle,
    required Difficulty difficulty,
  }) => GameState(
    puzzle: puzzle,
    difficulty: difficulty,
    grid: puzzle.given.clone(),
    notes: List.generate(81, (_) => {}),
    history: const [],
  );

  GameState copyWith({
    Puzzle? puzzle,
    Difficulty? difficulty,
    SudokuGrid? grid,
    List<Set<int>>? notes,
    List<GameAction>? history,
    bool? puzzleComplete,
    Duration? elapsed,
    GameAssists? assists,
  }) => GameState(
    puzzle: puzzle ?? this.puzzle,
    difficulty: difficulty ?? this.difficulty,
    grid: grid ?? this.grid,
    notes: notes ?? this.notes,
    history: history ?? this.history,
    puzzleComplete: puzzleComplete ?? this.puzzleComplete,
    elapsed: elapsed ?? this.elapsed,
    assists: assists ?? this.assists,
  );

  @override
  int get hashCode => Object.hash(
    puzzle,
    difficulty,
    grid,
    Object.hashAll(notes.expand((s) => s)),
    Object.hashAll(history),
    puzzleComplete,
    elapsed,
    assists,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          puzzle == other.puzzle &&
          difficulty == other.difficulty &&
          grid == other.grid &&
          listEquals(notes, other.notes) &&
          listEquals(history, other.history) &&
          puzzleComplete == other.puzzleComplete &&
          elapsed == other.elapsed &&
          assists == other.assists;

  factory GameState.fromJson(Map<String, dynamic> json) {
    final given = SudokuGrid(
      values: List<int>.from(json['givenValues'] as List),
    );
    final solution = SudokuGrid(
      values: List<int>.from(json['solutionValues'] as List),
    );
    final grid = SudokuGrid(values: List<int>.from(json['gridValues'] as List));
    final notes = (json['notes'] as List)
        .map((e) => Set<int>.from(e as List))
        .toList();
    final assistsMap = Map<String, dynamic>.from(json['assists'] as Map);

    return GameState(
      difficulty: Difficulty.fromValue(json['difficulty'] as int),
      elapsed: Duration(seconds: json['elapsed'] as int),
      puzzle: Puzzle(given: given, solution: solution),
      grid: grid,
      notes: notes,
      history: const [],
      assists: GameAssists(
        hints: assistsMap['hints'] as bool,
        autoNotes: assistsMap['autoNotes'] as bool,
        validation: assistsMap['validation'] as bool,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty.value,
    'elapsed': elapsed.inSeconds,
    'gridValues': grid.values,
    'solutionValues': puzzle.solution.values,
    'givenValues': puzzle.given.values,
    'notes': notes.map((s) => s.toList()).toList(),
    'assists': {
      'hints': assists.hints,
      'autoNotes': assists.autoNotes,
      'validation': assists.validation,
    },
  };
}
