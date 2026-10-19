import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sudoku/providers/settings_provider.dart';

class GameLayout extends ConsumerWidget {
  const new({
    required this.grid,
    required this.digitPad,
    required this.actionRow,
    this.gridTopSpacingFraction,
    super.key,
  });

  final Widget grid;
  final Widget digitPad;
  final Widget actionRow;
  final double? gridTopSpacingFraction;

  static const double _landscapeGridSizeFraction = 0.6;
  static const double _portraitSpacing = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPortrait = MediaQuery.orientationOf(context) == .portrait;
    if (!isPortrait) {
      return _landscape(context);
    }

    final override = gridTopSpacingFraction;
    final double fraction = override != null
        ? override.clamp(0.0, 1.0)
        : ref
              .watch(settingsProvider.select((s) => s.gridTopSpacingFraction))
              .clamp(0.0, 1.0);
    return _portrait(fraction);
  }

  Widget _portrait(double fraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxHeight.isFinite) {
          return Column(
            mainAxisSize: .min,
            spacing: _portraitSpacing,
            children: [grid, digitPad, actionRow],
          );
        }

        final topFlex = (fraction * 1000).round();
        final bottomFlex = 1000 - topFlex;
        return Column(
          spacing: _portraitSpacing,
          children: [
            if (topFlex > 0) Spacer(flex: topFlex),
            grid,
            if (bottomFlex > 0) Spacer(flex: bottomFlex),
            digitPad,
            actionRow,
          ],
        );
      },
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
      mainAxisAlignment: .center,
      children: [gridWidget, digitPad],
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
