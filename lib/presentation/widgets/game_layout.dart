import 'package:flutter/material.dart';
import 'package:sudoku/presentation/shared/grid_placement.dart';

class GameLayoutParams {
  const GameLayoutParams({
    this.placement = GridPlacement.left,
    this.expandedGridGap = 12.0,
    this.expandedControlsWidth = 320.0,
    this.compactGridGap = 8.0,
    this.gridWidth = 0.0,
    this.horizontalSpacing = 8.0,
    this.verticalSpacing = 8.0,
  });

  final GridPlacement placement;

  final double expandedGridGap;

  final double expandedControlsWidth;

  final double compactGridGap;

  final double gridWidth;

  final double horizontalSpacing;

  final double verticalSpacing;

  static const GameLayoutParams desktop = GameLayoutParams();

  static const GameLayoutParams mobile = GameLayoutParams(
    placement: GridPlacement.top,
  );

  GameLayoutParams copyWith({
    GridPlacement? placement,
    double? expandedGridGap,
    double? expandedControlsWidth,
    double? compactGridGap,
    double? gridWidth,
    double? horizontalSpacing,
    double? verticalSpacing,
  }) => GameLayoutParams(
    placement: placement ?? this.placement,
    expandedGridGap: expandedGridGap ?? this.expandedGridGap,
    expandedControlsWidth: expandedControlsWidth ?? this.expandedControlsWidth,
    compactGridGap: compactGridGap ?? this.compactGridGap,
    gridWidth: gridWidth ?? this.gridWidth,
    horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
    verticalSpacing: verticalSpacing ?? this.verticalSpacing,
  );
}

class GameLayout extends StatelessWidget {
  const GameLayout({
    required this.params,
    required this.grid,
    required this.actionRow,
    required this.digitPad,
    required this.isExpanded,
    super.key,
  });

  final GameLayoutParams params;

  final Widget grid;

  final Widget actionRow;

  final Widget digitPad;

  final bool isExpanded;

  bool get _horizontal =>
      placement == GridPlacement.left || placement == GridPlacement.right;

  GridPlacement get placement => params.placement;

  @override
  Widget build(BuildContext context) {
    final p = params;
    final mq = MediaQuery.of(context);

    if (isExpanded && _horizontal) {
      return SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: p.horizontalSpacing,
                right: p.horizontalSpacing,
                top: p.verticalSpacing,
                bottom: 80,
              ),
              child: Row(
                children: [
                  Expanded(child: Center(child: grid)),
                  SizedBox(width: p.expandedGridGap),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [digitPad],
                  ),
                ],
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: actionRow),
          ],
        ),
      );
    }

    final gridPad = p.gridWidth > 0
        ? ((mq.size.width - p.gridWidth) / 2).clamp(0.0, double.infinity)
        : 16.0;
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: p.horizontalSpacing,
              right: p.horizontalSpacing,
              top: p.verticalSpacing,
              bottom: 140,
            ),
            child: Center(child: grid),
          ),
          Positioned(
            left: gridPad,
            right: gridPad,
            bottom: 80,
            child: digitPad,
          ),
          Positioned(left: 0, right: 0, bottom: 16, child: actionRow),
        ],
      ),
    );
  }
}
