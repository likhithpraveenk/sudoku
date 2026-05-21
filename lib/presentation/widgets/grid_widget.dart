import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/presentation/widgets/notes_grid.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';

class GridWidget extends StatelessWidget {
  const GridWidget({required this.gameState, super.key});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final availableHeight =
        mq.height - (Scaffold.of(context).appBarMaxHeight ?? 56.0) - 220.0;
    final maxGrid = context.isExpanded
        ? mq.height - 120
        : (availableHeight > 200 ? availableHeight : mq.width - 16);
    final size = maxGrid.clamp(0.0, mq.width - 16).clamp(0.0, 520.0);

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 81,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemBuilder: (_, index) {
            return _Cell(index: index, gameState: gameState, size: size / 9);
          },
        ),
      ),
    );
  }
}

class _Cell extends ConsumerWidget {
  const _Cell({
    required this.index,
    required this.gameState,
    required this.size,
  });
  final int index;
  final GameState gameState;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final board = ref.watch(boardProvider);

    final isSelected = board.selectedCell == index;
    final isGiven = gameState.puzzle.isGivenAt(index);
    final isError = board.errorCells.contains(index);

    final value = gameState.grid.valueAt(index);
    final notes = gameState.notes[index];

    final activeDigit =
        board.selectedDigit ??
        (board.selectedCell != null
            ? gameState.grid.valueAt(board.selectedCell!)
            : null);

    final isSameDigit = activeDigit != 0 && activeDigit == value;
    final hasNote = activeDigit != 0 && notes.contains(activeDigit);

    final r = index ~/ 9;
    final c = index % 9;

    final thin = BorderSide(color: scheme.outlineVariant, width: 0.7);

    final thick = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.45),
      width: 1.6,
    );

    final tileColor = isGiven
        ? (isSelected || isSameDigit ? scheme.primary : scheme.outlineVariant)
        : (isSelected || isSameDigit || hasNote
              ? scheme.primary
              : scheme.surface);

    final foreground = isGiven
        ? scheme.surface
        : (isSelected || isSameDigit ? scheme.surface : scheme.onSurface);

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        if (board.inputMode == .pencil && board.selectedDigit != null) {
          ref
              .read(gameProvider.notifier)
              .inputDigit(index, board.selectedDigit!);
        } else {
          ref.read(boardProvider.notifier).selectCell(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: r == 0 ? .none : (r % 3 == 0 ? thick : thin),
            left: c == 0 ? .none : (c % 3 == 0 ? thick : thin),
          ),
        ),
        child: Padding(
          padding: const .all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: .circular(6),
              border: .all(
                width: 0.8,
                color: isSelected ? scheme.errorContainer : Colors.transparent,
              ),
            ),
            child: value != 0
                ? Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: size * 0.52,
                        fontWeight: .w500,
                        color: isError ? scheme.error : foreground,
                      ),
                    ),
                  )
                : notes.isNotEmpty
                ? Padding(
                    padding: const .all(2),
                    child: NotesGrid(
                      notes: notes,
                      cellSize: size,
                      hasNoteOfSameDigit: hasNote || isSelected,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
