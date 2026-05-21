import 'package:flutter/widgets.dart';

enum ScreenLayout { compact, medium, expanded }

extension LayoutContext on BuildContext {
  ScreenLayout get layout {
    final w = MediaQuery.of(this).size.width;
    if (w < 600) return ScreenLayout.compact;
    if (w < 840) return ScreenLayout.medium;
    return ScreenLayout.expanded;
  }

  bool get isExpanded => layout == ScreenLayout.expanded;
}
