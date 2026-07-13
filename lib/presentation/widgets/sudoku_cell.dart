import 'package:flutter/material.dart';
import 'package:sudoku/presentation/widgets/notes_grid.dart';

class SudokuCell extends StatelessWidget {
  const SudokuCell({
    required this.index,
    required this.size,
    required this.value,
    required this.notes,
    required this.isGiven,
    required this.isSelected,
    required this.isError,
    required this.isSameDigit,
    required this.hasNoteOfSameDigit,
    required this.maskGivenCells,
    super.key,
  });

  final int index;
  final double size;
  final int value;
  final Set<int> notes;
  final bool isGiven;
  final bool isSelected;
  final bool isError;
  final bool isSameDigit;
  final bool hasNoteOfSameDigit;
  final bool maskGivenCells;

  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final r = index ~/ 9;
    final c = index % 9;

    final thin = BorderSide(color: scheme.outlineVariant, width: 0.8);

    final thick = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.8),
      width: 1.6,
    );

    final tileColor = isGiven
        ? (isSelected || isSameDigit
              ? scheme.primary
              : maskGivenCells
              ? scheme.outlineVariant
              : scheme.surface)
        : (isSelected || isSameDigit || hasNoteOfSameDigit
              ? scheme.primary
              : scheme.surface);

    final foreground = isGiven && maskGivenCells
        ? scheme.surface
        : (isSelected || isSameDigit ? scheme.surface : scheme.onSurface);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: r == 0 ? .none : (r % 3 == 0 ? thick : thin),
          left: c == 0 ? .none : (c % 3 == 0 ? thick : thin),
        ),
      ),
      child: Padding(
        padding: const .all(2),
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          decoration: BoxDecoration(
            color: isError ? scheme.errorContainer : tileColor,
            borderRadius: .circular(6),
            border: .all(
              width: 1,
              color: isSelected ? scheme.errorContainer : Colors.transparent,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            switchInCurve: _curve,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: .96, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: switch (value) {
              > 0 => Center(
                key: ValueKey(value),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: size * .52,
                    fontWeight: .w500,
                    color: isError ? scheme.onErrorContainer : foreground,
                  ),
                ),
              ),
              _ when notes.isNotEmpty => Padding(
                key: const ValueKey('notes'),
                padding: const .all(2),
                child: NotesGrid(
                  notes: notes,
                  cellSize: size,
                  hasNoteOfSameDigit: hasNoteOfSameDigit || isSelected,
                ),
              ),
              _ => const SizedBox.shrink(key: ValueKey('empty')),
            },
          ),
        ),
      ),
    );
  }
}
