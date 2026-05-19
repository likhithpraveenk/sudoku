import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/presentation/widgets/notes_grid.dart';
import 'package:sudoku/providers/game_notifier.dart';

/// An interactive 9x9 board that renders the active Sudoku grid.
///
/// This widget automatically calculates and adjusts its size based on the
/// screen dimensions (compact vs. expanded layouts) and limits its maximum size
/// to ensure a clean visual balance. It registers touch gestures for selecting
/// cells and coordinates highlighting corresponding to:
/// * The currently selected cell
/// * Cells containing the same digit value
/// * Cells containing notes matching the selected digit
class GridWidget extends ConsumerWidget {
  /// Creates a new interactive Sudoku grid widget.
  const GridWidget({required this.state, super.key});

  /// The active state of the current game.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context).size;
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
            return _Cell(index: index, state: state, size: size / 9);
          },
        ),
      ),
    );
  }
}

class _Cell extends ConsumerWidget {
  const _Cell({required this.index, required this.state, required this.size});
  final int index;
  final GameState state;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = state.selectedCell == index;
    final isGiven = state.puzzle.isGivenAt(index);
    final isError = state.errorCells.contains(index);
    final isRevealed = state.revealedCells.contains(index);
    final value = state.grid.valueAt(index);
    final notes = state.notes[index];

    final activeDigit =
        state.selectedDigit ??
        (state.selectedCell != null
            ? state.grid.valueAt(state.selectedCell!)
            : null);

    final isSameDigit =
        activeDigit != null && activeDigit != 0 && activeDigit == value;
    final hasNote =
        activeDigit != null && activeDigit != 0 && notes.contains(activeDigit);

    var bg = cs.surface;
    if (isSelected) {
      bg = cs.primaryContainer;
    } else if (isSameDigit) {
      bg = cs.primaryContainer.withValues(alpha: 0.5);
    } else if (hasNote) {
      bg = cs.primaryContainer.withValues(alpha: 0.2);
    }

    var textColor = cs.onSurface;
    if (isError) {
      textColor = cs.error;
    } else if (isRevealed) {
      textColor = cs.primary;
    } else if (!isGiven) {
      textColor = cs.primary.withValues(alpha: 0.85);
    }

    final r = index ~/ 9;
    final c = index % 9;

    return GestureDetector(
      onTap: () {
        ref.read(gameProvider.notifier).selectCell(isSelected ? null : index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: r % 3 == 0
                ? const BorderSide(color: Colors.black87, width: 2)
                : const BorderSide(color: Colors.black26, width: 0.5),
            left: c % 3 == 0
                ? const BorderSide(color: Colors.black87, width: 2)
                : const BorderSide(color: Colors.black26, width: 0.5),
            bottom: r == 8
                ? const BorderSide(color: Colors.black87, width: 2)
                : BorderSide.none,
            right: c == 8
                ? const BorderSide(color: Colors.black87, width: 2)
                : BorderSide.none,
          ),
        ),
        child: value != 0
            ? Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: size * 0.52,
                    fontWeight: isGiven ? FontWeight.w800 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              )
            : notes.isNotEmpty
            ? NotesGrid(notes: notes, cellSize: size)
            : const SizedBox.shrink(),
      ),
    );
  }
}
