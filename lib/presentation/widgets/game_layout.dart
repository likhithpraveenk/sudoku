import 'package:flutter/material.dart';

class GameLayout extends StatelessWidget {
  const GameLayout({
    required this.grid,
    required this.digitPad,
    required this.actionRow,
    super.key,
  });

  final Widget grid;
  final Widget digitPad;
  final Widget actionRow;

  static const double _landscapeGridSizeFraction = 0.6;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == .portrait;
    return isPortrait ? _portrait(context) : _landscape(context);
  }

  Widget _portrait(BuildContext context) {
    return Column(
      mainAxisAlignment: .end,
      spacing: 16,
      children: [grid, digitPad, actionRow],
    );
  }

  Widget _landscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    final available = size.width - padding.left - padding.right;
    final gridSize = (available * _landscapeGridSizeFraction).clamp(
      0.0,
      size.height - 80,
    );

    final gridWidget = SizedBox(width: gridSize, height: gridSize, child: grid);

    final row = Row(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      children: [gridWidget, const SizedBox(width: 16), digitPad],
    );

    return Column(
      children: [
        Expanded(child: Center(child: row)),
        actionRow,
        const SizedBox(height: 12),
      ],
    );
  }
}
