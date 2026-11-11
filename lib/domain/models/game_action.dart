import 'package:sudoku/domain/models/game_state.dart';

sealed class GameAction {
  const new();

  GameState undo(GameState state);

  Map<String, dynamic> toJson();

  factory fromJson(Map<String, dynamic> json) => switch (json['type']) {
    'digit' => DigitAction(
      cellIndex: json['cell'] as int,
      previousValue: json['previousValue'] as int,
      previousNotes: _notesMapFromJson(json['previousNotes']),
      newValue: json['newValue'] as int,
    ),
    'pencil' => PencilAction(
      cellIndex: json['cell'] as int,
      previousNotes: _notesFromJson(json['previousNotes']),
      newNotes: _notesFromJson(json['newNotes']),
      previousValue: json['previousValue'] as int,
    ),
    'erase' => EraseAction(
      cellIndex: json['cell'] as int,
      previousValue: json['previousValue'] as int,
      previousNotes: _notesFromJson(json['previousNotes']),
    ),
    'autoNotes' => AutoNotesAction(
      previousNotes: [
        for (final notes in json['previousNotes'] as List)
          _notesFromJson(notes),
      ],
    ),
    _ => throw FormatException('Unknown action type: ${json['type']}'),
  };

  /// Decodes the history of a saved game.
  ///
  /// A history that cannot be read is dropped rather than failing the load, so
  /// the board itself still opens and undo simply starts from there. Saves
  /// written before the history was stored have no key at all.
  static List<GameAction> listFromJson(Object? json) {
    if (json is! List) return const [];
    try {
      return [
        for (final entry in json)
          GameAction.fromJson(Map<String, dynamic>.from(entry as Map)),
      ];
    } on Object {
      return const [];
    }
  }
}

class DigitAction extends GameAction {
  const new({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
    required this.newValue,
  });

  final int cellIndex;

  final int previousValue;

  final Map<int, Set<int>> previousNotes;

  final int newValue;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    previousNotes.forEach((i, notes) {
      newNotes[i] = Set<int>.from(notes);
    });
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'digit',
    'cell': cellIndex,
    'previousValue': previousValue,
    'newValue': newValue,
    'previousNotes': _notesMapToJson(previousNotes),
  };
}

class PencilAction extends GameAction {
  const new({
    required this.cellIndex,
    required this.previousNotes,
    required this.newNotes,
    required this.previousValue,
  });

  final int cellIndex;

  final Set<int> previousNotes;

  final Set<int> newNotes;

  final int previousValue;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    newNotes[cellIndex] = Set<int>.from(previousNotes);
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'pencil',
    'cell': cellIndex,
    'previousValue': previousValue,
    'previousNotes': previousNotes.toList(),
    'newNotes': newNotes.toList(),
  };
}

class EraseAction extends GameAction {
  const new({
    required this.cellIndex,
    required this.previousValue,
    required this.previousNotes,
  });

  final int cellIndex;

  final int previousValue;

  final Set<int> previousNotes;

  @override
  GameState undo(GameState state) {
    final newNotes = List<Set<int>>.from(state.notes.map(Set<int>.from));
    newNotes[cellIndex] = Set<int>.from(previousNotes);
    final grid = state.grid.clone()..setValue(cellIndex, previousValue);
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(grid: grid, notes: newNotes, history: trimmed);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'erase',
    'cell': cellIndex,
    'previousValue': previousValue,
    'previousNotes': previousNotes.toList(),
  };
}

class AutoNotesAction extends GameAction {
  const new({required this.previousNotes});

  final List<Set<int>> previousNotes;

  @override
  GameState undo(GameState state) {
    final trimmed = state.history.sublist(0, state.history.length - 1);
    return state.copyWith(
      notes: previousNotes.map(Set<int>.from).toList(),
      history: trimmed,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'autoNotes',
    'previousNotes': [for (final notes in previousNotes) notes.toList()],
  };
}

Set<int> _notesFromJson(Object? json) => Set<int>.from(json as List);

Map<int, Set<int>> _notesMapFromJson(Object? json) => {
  for (final entry in (json as Map).entries)
    int.parse(entry.key as String): Set<int>.from(entry.value as List),
};

Map<String, dynamic> _notesMapToJson(Map<int, Set<int>> notes) => {
  for (final entry in notes.entries) '${entry.key}': entry.value.toList(),
};
