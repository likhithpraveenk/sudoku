import 'package:flutter/material.dart';

enum NotesLayout {
  grid,
  fixed;

  String get label => switch (this) {
    grid => 'Compact',
    fixed => 'Fixed',
  };

  String get description => switch (this) {
    grid => 'Packs notes into rows, using as little space as possible',
    fixed => 'Each note is fixed its slot in mini 3x3 grid',
  };
}

class AppSettings {
  const AppSettings({
    this.showRemainingCounts = true,
    this.showTimer = true,
    this.maskGivenCells = true,
    this.autoRemoveNotes = true,
    this.highlightSameDigits = true,
    this.trueBlackMode = false,
    this.schemeVariant = .tonalSpot,
    this.notesLayout = .grid,
  });

  final bool showRemainingCounts;
  final bool showTimer;
  final bool maskGivenCells;
  final bool autoRemoveNotes;
  final bool highlightSameDigits;
  final bool trueBlackMode;
  final DynamicSchemeVariant schemeVariant;
  final NotesLayout notesLayout;

  AppSettings copyWith({
    bool? showRemainingCounts,
    bool? showTimer,
    bool? maskGivenCells,
    bool? autoRemoveNotes,
    bool? highlightSameDigits,
    bool? trueBlackMode,
    DynamicSchemeVariant? schemeVariant,
    NotesLayout? notesLayout,
  }) => AppSettings(
    showRemainingCounts: showRemainingCounts ?? this.showRemainingCounts,
    showTimer: showTimer ?? this.showTimer,
    maskGivenCells: maskGivenCells ?? this.maskGivenCells,
    autoRemoveNotes: autoRemoveNotes ?? this.autoRemoveNotes,
    highlightSameDigits: highlightSameDigits ?? this.highlightSameDigits,
    trueBlackMode: trueBlackMode ?? this.trueBlackMode,
    schemeVariant: schemeVariant ?? this.schemeVariant,
    notesLayout: notesLayout ?? this.notesLayout,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showRemainingCounts: json['showRemainingCounts'] as bool? ?? true,
      showTimer: json['showTimer'] as bool? ?? true,
      maskGivenCells: json['maskGivenCells'] as bool? ?? true,
      autoRemoveNotes: json['autoRemoveNotes'] as bool? ?? true,
      highlightSameDigits: json['highlightSameDigits'] as bool? ?? true,
      trueBlackMode: json['trueBlackMode'] as bool? ?? false,
      schemeVariant: .values.firstWhere(
        (v) => v.name == json['schemeVariant'],
        orElse: () => .tonalSpot,
      ),
      notesLayout: NotesLayout.values.firstWhere(
        (v) => v.name == json['notesLayout'],
        orElse: () => .grid,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'showRemainingCounts': showRemainingCounts,
    'showTimer': showTimer,
    'maskGivenCells': maskGivenCells,
    'autoRemoveNotes': autoRemoveNotes,
    'highlightSameDigits': highlightSameDigits,
    'trueBlackMode': trueBlackMode,
    'schemeVariant': schemeVariant.name,
    'notesLayout': notesLayout.name,
  };
}
