import 'package:sudoku/presentation/shared/grid_placement.dart';

class AppSettings {
  const AppSettings({
    this.showRemaining = true,
    this.showTimer = true,
    this.gridWidth = 360,
    this.horizontalSpacing = 16,
    this.verticalSpacing = 24,
    this.placement = .top,
  });

  final bool showRemaining;
  final bool showTimer;
  final double gridWidth;
  final double horizontalSpacing;
  final double verticalSpacing;
  final GridPlacement placement;

  AppSettings copyWith({
    bool? showRemaining,
    bool? showTimer,
    double? gridWidth,
    double? horizontalSpacing,
    double? verticalSpacing,
    GridPlacement? placement,
  }) => AppSettings(
    showRemaining: showRemaining ?? this.showRemaining,
    showTimer: showTimer ?? this.showTimer,
    gridWidth: gridWidth ?? this.gridWidth,
    horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
    verticalSpacing: verticalSpacing ?? this.verticalSpacing,
    placement: placement ?? this.placement,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    showRemaining: json['showRemaining'] as bool,
    showTimer: json['showTimer'] as bool,
    gridWidth: (json['gridWidth'] as num).toDouble(),
    horizontalSpacing: (json['horizontalSpacing'] as num).toDouble(),
    verticalSpacing: (json['verticalSpacing'] as num).toDouble(),
    placement: GridPlacement.values.firstWhere(
      (e) => e.name == json['placement'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'showRemaining': showRemaining,
    'showTimer': showTimer,
    'gridWidth': gridWidth,
    'horizontalSpacing': horizontalSpacing,
    'verticalSpacing': verticalSpacing,
    'placement': placement.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.showRemaining == showRemaining &&
          other.showTimer == showTimer &&
          other.gridWidth == gridWidth &&
          other.horizontalSpacing == horizontalSpacing &&
          other.verticalSpacing == verticalSpacing &&
          other.placement == placement;

  @override
  int get hashCode => Object.hash(
    showRemaining,
    showTimer,
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
