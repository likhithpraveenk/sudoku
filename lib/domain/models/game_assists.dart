class GameAssists {
  const GameAssists({
    this.hints = false,
    this.autoNotes = false,
    this.validation = false,
  });
  final bool hints;
  final bool autoNotes;
  final bool validation;

  GameAssists copyWith({bool? hints, bool? autoNotes, bool? validation}) =>
      GameAssists(
        hints: hints ?? this.hints,
        autoNotes: autoNotes ?? this.autoNotes,
        validation: validation ?? this.validation,
      );

  @override
  int get hashCode => Object.hash(hints, autoNotes, validation);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAssists &&
          hints == other.hints &&
          autoNotes == other.autoNotes &&
          validation == other.validation;
}
