import 'package:flutter/material.dart';
import 'package:sudoku/presentation/models/app_settings.dart';
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
    this.notesLayout = .grid,
    this.removeAnimations = false,
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
  final NotesLayout notesLayout;
  final bool removeAnimations;

  Duration get _animationDuration =>
      removeAnimations ? Duration.zero : const Duration(milliseconds: 250);
  Curve get _animationCurve =>
      removeAnimations ? Curves.linear : Curves.easeInBack;

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

    final baseColor = isGiven && maskGivenCells
        ? scheme.outlineVariant
        : scheme.surface;

    final highlightColor = isError ? scheme.errorContainer : scheme.primary;

    final foreground = isGiven && maskGivenCells
        ? scheme.surface
        : (isSelected || isSameDigit ? scheme.surface : scheme.onSurface);

    final isHighlighted =
        isError || isSelected || isSameDigit || hasNoteOfSameDigit;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: r == 0 ? .none : (r % 3 == 0 ? thick : thin),
          left: c == 0 ? .none : (c % 3 == 0 ? thick : thin),
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: TweenAnimationBuilder<double>(
        duration: _animationDuration,
        curve: isHighlighted ? Curves.easeOutBack : Curves.easeOutCubic,
        tween: Tween(begin: 0, end: isHighlighted ? 1.0 : 0.0),
        builder: (context, scale, child) {
          return Stack(
            alignment: .center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: .circular(6),
                ),
              ),
              Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: _animationDuration,
                  curve: _animationCurve,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: .circular(6),
                    border: .all(
                      width: 2,
                      color: isSelected
                          ? scheme.errorContainer
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              ?child,
            ],
          );
        },
        child: AnimatedSwitcher(
          duration: _animationDuration,
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
                  fontSize: size * .54,
                  fontWeight: .w500,
                  color: isError ? scheme.onErrorContainer : foreground,
                ),
              ),
            ),
            _ when notes.isNotEmpty => Padding(
              key: const ValueKey('notes'),
              padding: const .all(2),
              child: switch (notesLayout) {
                .grid => NotesGrid(
                  notes: notes,
                  cellSize: size,
                  hasNoteOfSameDigit: hasNoteOfSameDigit || isSelected,
                ),
                .fixed => FixedNotesGrid(
                  notes: notes,
                  cellSize: size,
                  hasNoteOfSameDigit: hasNoteOfSameDigit || isSelected,
                ),
              },
            ),
            _ => const SizedBox.shrink(key: ValueKey('empty')),
          },
        ),
      ),
    );
  }
}
