import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.showRemainingCounts = true,
    this.showTimer = true,
    this.maskGivenCells = true,
    this.autoRemoveNotes = true,
    this.highlightSameDigits = true,
    this.trueBlackMode = false,
    this.schemeVariant = .tonalSpot,
  });

  final bool showRemainingCounts;
  final bool showTimer;
  final bool maskGivenCells;
  final bool autoRemoveNotes;
  final bool highlightSameDigits;
  final bool trueBlackMode;
  final DynamicSchemeVariant schemeVariant;

  AppSettings copyWith({
    bool? showRemainingCounts,
    bool? showTimer,
    bool? maskGivenCells,
    bool? autoRemoveNotes,
    bool? highlightSameDigits,
    bool? trueBlackMode,
    DynamicSchemeVariant? schemeVariant,
  }) => AppSettings(
    showRemainingCounts: showRemainingCounts ?? this.showRemainingCounts,
    showTimer: showTimer ?? this.showTimer,
    maskGivenCells: maskGivenCells ?? this.maskGivenCells,
    autoRemoveNotes: autoRemoveNotes ?? this.autoRemoveNotes,
    highlightSameDigits: highlightSameDigits ?? this.highlightSameDigits,
    trueBlackMode: trueBlackMode ?? this.trueBlackMode,
    schemeVariant: schemeVariant ?? this.schemeVariant,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    showRemainingCounts: json['showRemainingCounts'] as bool,
    showTimer: json['showTimer'] as bool,
    maskGivenCells: json['maskGivenCells'] as bool,
    autoRemoveNotes: json['autoRemoveNotes'] as bool,
    highlightSameDigits: json['highlightSameDigits'] as bool,
    trueBlackMode: json['trueBlackMode'] as bool,
    schemeVariant: DynamicSchemeVariant.values.firstWhere(
      (v) => v.name == json['schemeVariant'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'showRemainingCounts': showRemainingCounts,
    'showTimer': showTimer,
    'maskGivenCells': maskGivenCells,
    'autoRemoveNotes': autoRemoveNotes,
    'highlightSameDigits': highlightSameDigits,
    'trueBlackMode': trueBlackMode,
    'schemeVariant': schemeVariant.name,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}
