import 'package:sudoku/presentation/shared/grid_placement.dart';

class AppSettings {
  const AppSettings({
    this.showRemainingCounts = true,
    this.showTimer = true,
    this.maskGivenCells = true,
    this.autoRemoveNotes = true,
    this.highlightSameDigits = true,
    this.gridWidth = 360,
    this.horizontalSpacing = 16,
    this.verticalSpacing = 24,
    this.placement = .top,
  });

  final bool showRemainingCounts;
  final bool showTimer;
  final bool maskGivenCells;
  final bool autoRemoveNotes;
  final bool highlightSameDigits;
  final double gridWidth;
  final double horizontalSpacing;
  final double verticalSpacing;
  final GridPlacement placement;

  AppSettings copyWith({
    bool? showRemainingCounts,
    bool? showTimer,
    bool? maskGivenCells,
    bool? autoRemoveNotes,
    bool? highlightSameDigits,
    double? gridWidth,
    double? horizontalSpacing,
    double? verticalSpacing,
    GridPlacement? placement,
  }) => AppSettings(
    showRemainingCounts: showRemainingCounts ?? this.showRemainingCounts,
    showTimer: showTimer ?? this.showTimer,
    maskGivenCells: maskGivenCells ?? this.maskGivenCells,
    autoRemoveNotes: autoRemoveNotes ?? this.autoRemoveNotes,
    highlightSameDigits: highlightSameDigits ?? this.highlightSameDigits,
    gridWidth: gridWidth ?? this.gridWidth,
    horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
    verticalSpacing: verticalSpacing ?? this.verticalSpacing,
    placement: placement ?? this.placement,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    showRemainingCounts: json['showRemainingCounts'] as bool,
    showTimer: json['showTimer'] as bool,
    maskGivenCells: json['maskGivenCells'] as bool,
    autoRemoveNotes: json['autoRemoveNotes'] as bool,
    highlightSameDigits: json['highlightSameDigits'] as bool,
    gridWidth: (json['gridWidth'] as num).toDouble(),
    horizontalSpacing: (json['horizontalSpacing'] as num).toDouble(),
    verticalSpacing: (json['verticalSpacing'] as num).toDouble(),
    placement: GridPlacement.values.firstWhere(
      (e) => e.name == json['placement'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'showRemainingCounts': showRemainingCounts,
    'showTimer': showTimer,
    'maskGivenCells': maskGivenCells,
    'autoRemoveNotes': autoRemoveNotes,
    'highlightSameDigits': highlightSameDigits,
    'gridWidth': gridWidth,
    'horizontalSpacing': horizontalSpacing,
    'verticalSpacing': verticalSpacing,
    'placement': placement.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.showRemainingCounts == showRemainingCounts &&
          other.showTimer == showTimer &&
          other.maskGivenCells == maskGivenCells &&
          other.autoRemoveNotes == autoRemoveNotes &&
          other.highlightSameDigits == highlightSameDigits &&
          other.gridWidth == gridWidth &&
          other.horizontalSpacing == horizontalSpacing &&
          other.verticalSpacing == verticalSpacing &&
          other.placement == placement;

  @override
  int get hashCode => Object.hash(
    showRemainingCounts,
    showTimer,
    maskGivenCells,
    autoRemoveNotes,
    highlightSameDigits,
    gridWidth,
    horizontalSpacing,
    verticalSpacing,
    placement,
  );

  @override
  String toString() {
    return toJson().toString();
  }
}
