import 'package:material_ui/material_ui.dart';

class PreviewOverlay {
  OverlayEntry? _entry;

  bool get visible => _entry != null;

  void show(BuildContext context, WidgetBuilder builder) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(child: builder(ctx)),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}
