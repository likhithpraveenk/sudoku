import 'dart:ui';

import 'package:flutter/material.dart';

class NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    .touch,
    .mouse,
    .stylus,
    .trackpad,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
