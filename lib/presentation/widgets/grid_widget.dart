import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/presentation/widgets/sudoku_cell.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/settings_provider.dart';

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

    return IgnorePointer(
      ignoring: gameState.puzzleComplete,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                  return _Cell(
                    index: index,
                    gameState: gameState,
                    size: size / 9,
                  );
                },
              ),
            ),
          );
        },
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
    final settings = ref.watch(settingsProvider);
    final highlightSameDigits = settings.highlightSameDigits;
    final maskGivenCells = settings.maskGivenCells;

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

    final isSameDigit =
        highlightSameDigits &&
        activeDigit != null &&
        activeDigit != 0 &&
        activeDigit == value;
    final hasNote =
        highlightSameDigits &&
        activeDigit != null &&
        activeDigit != 0 &&
        notes.contains(activeDigit);

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        if (isError) {
          ref.read(boardProvider.notifier).removeErrorCell(index);
        }
        if (board.selectedDigit != null) {
          ref
              .read(gameProvider.notifier)
              .inputDigit(index, board.selectedDigit!);
        } else {
          ref.read(boardProvider.notifier).selectCell(index);
        }
      },
      onLongPress: () {
        ref.read(gameProvider.notifier).erase(index);
      },
      child: SudokuCell(
        index: index,
        size: size,
        value: value,
        notes: notes,
        isGiven: isGiven,
        isSelected: isSelected,
        isError: isError,
        isSameDigit: isSameDigit,
        hasNoteOfSameDigit: hasNote || isSelected,
        maskGivenCells: maskGivenCells,
      ),
    );
  }
}
