import 'package:flutter/material.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';
import 'package:sudoku/presentation/widgets/digit_pad.dart';
import 'package:sudoku/presentation/widgets/sudoku_cell.dart';

class GamePreview extends StatelessWidget {
  const GamePreview({
    required this.showRemainingCounts,
    required this.maskGivenCells,
    required this.highlightSameDigits,
    super.key,
  });

  final bool showRemainingCounts;
  final bool maskGivenCells;
  final bool highlightSameDigits;

  @override
  Widget build(BuildContext context) {
    const double gridSize = 220.0;
    const double cellSize = gridSize / 9;

    final values = List<int>.filled(81, 0);
    final noteSets = List<Set<int>>.generate(81, (_) => <int>{});

    final puzzle = Puzzle(
      given: SudokuGrid.fromRows([
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ]),
      solution: SudokuGrid.fromRows([
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ]),
    );

    for (int i = 0; i < 81; i++) {
      values[i] = puzzle.given.valueAt(i);
    }

    values[2] = 4;
    values[18] = 1;
    values[21] = 3;
    values[37] = 5;
    values[54] = 9;

    noteSets[6] = {1, 8};
    noteSets[7] = {1};
    noteSets[10] = {2, 7};
    noteSets[11] = {2, 7};
    noteSets[24] = {5};
    noteSets[26] = {5};

    const selectedIndex = 21;

    const demoActiveDigit = 3;

    final counts = <int, int>{};
    for (final v in values) {
      if (v != 0) counts[v] = (counts[v] ?? 0) + 1;
    }

    final shouldHighlightDigit = highlightSameDigits ? demoActiveDigit : null;

    Widget buildCell(int index) {
      final value = values[index];
      final notes = noteSets[index];
      final isGiven = puzzle.isGivenAt(index);
      final isSelected = index == selectedIndex;

      final isSame =
          shouldHighlightDigit != null &&
          value != 0 &&
          value == shouldHighlightDigit;
      final hasNote =
          shouldHighlightDigit != null && notes.contains(shouldHighlightDigit);

      final isError = index == 37;

      return SudokuCell(
        index: index,
        size: cellSize,
        value: value,
        notes: notes,
        isGiven: isGiven,
        isSelected: isSelected,
        isError: isError,
        isSameDigit: isSame,
        hasNoteOfSameDigit: hasNote,
        maskGivenCells: maskGivenCells,
      );
    }

    final grid = SizedBox(
      width: gridSize,
      height: gridSize,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 81,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (_, index) => buildCell(index),
      ),
    );

    const double btnSize = 26.0;
    final digitButtons = <Widget>[];
    for (int i = 1; i <= 9; i++) {
      final count = counts[i] ?? 0;
      final isActive = i == demoActiveDigit;
      digitButtons.add(
        DigitButton(
          digit: '$i',
          active: isActive,
          count: count,
          showCount: showRemainingCounts,
          onTap: () {},
          size: btnSize,
        ),
      );
    }
    digitButtons.add(
      DigitButton(
        digit: 'X',
        active: false,
        count: 9,
        showCount: false,
        onTap: () {},
        size: btnSize,
      ),
    );

    final digitPad = Column(
      mainAxisSize: .min,
      children: [
        Wrap(spacing: 4, children: digitButtons.sublist(0, 5)),
        const SizedBox(height: 4),
        Wrap(spacing: 4, children: digitButtons.sublist(5)),
      ],
    );

    Widget actionBtn(IconData icon, {bool active = false}) {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? scheme.primary : Colors.transparent,
          borderRadius: .circular(6),
        ),
        child: Icon(
          icon,
          color: active ? scheme.surface : scheme.onSurface,
          size: 16,
        ),
      );
    }

    final actionRow = Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        actionBtn(Icons.refresh_rounded),
        actionBtn(Icons.lightbulb_outline_rounded),
        actionBtn(Icons.edit_outlined, active: true),
        actionBtn(Icons.undo_rounded),
      ],
    );

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: .circular(12),
        border: .all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          grid,
          const SizedBox(height: 10),
          digitPad,
          const SizedBox(height: 8),
          actionRow,
        ],
      ),
    );
  }
}
