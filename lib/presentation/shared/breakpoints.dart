import 'package:flutter/widgets.dart';

/// Represents the layout of the screen based on screen width.
enum ScreenLayout {
  /// Compact screen width (e.g., phones).
  compact,

  /// Medium screen width (e.g., tablets).
  medium,

  /// Expanded screen width (e.g., desktops).
  expanded,
}

/// Helper extension on [BuildContext] to get the layout classification.
extension LayoutContext on BuildContext {
  /// Gets the [ScreenLayout] class for the current screen.
  ScreenLayout get layout {
    final w = MediaQuery.of(this).size.width;
    if (w < 600) return ScreenLayout.compact;
    if (w < 840) return ScreenLayout.medium;
    return ScreenLayout.expanded;
  }

  /// Returns true if the layout is expanded.
  bool get isExpanded => layout == ScreenLayout.expanded;
}
