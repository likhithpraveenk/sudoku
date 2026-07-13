import 'package:flutter/material.dart';

class PreviewOverlay {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context,
    Widget child, {
    double? width,
    double? height,
    Offset? offset,
  }) {
    if (_entry != null) return;
    final size = MediaQuery.sizeOf(context);
    final w = width ?? size.width * 0.8;
    final h = height ?? size.height * 0.6;
    final left = offset?.dx ?? (size.width - w) / 2;
    final top = offset?.dy ?? (size.height - h) / 2;
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        width: w,
        height: h,
        child: Material(elevation: 12, color: Colors.transparent, child: child),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
