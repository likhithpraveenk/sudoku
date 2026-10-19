import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sudoku/domain/models/puzzle.dart';
import 'package:sudoku/domain/models/sudoku_grid.dart';
import 'package:sudoku/presentation/widgets/digit_pad.dart';
import 'package:sudoku/presentation/widgets/game_layout.dart';
import 'package:sudoku/presentation/widgets/sudoku_cell.dart';
import 'package:sudoku/providers/settings_provider.dart';

class GamePreviewScreen extends ConsumerWidget {
  const new({this.gridTopSpacingFraction, super.key});

  final double? gridTopSpacingFraction;

  static final Puzzle _demoPuzzle = Puzzle(
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

  static const _demoUserValues = {2: 4, 18: 1, 21: 3, 37: 5, 54: 9};
  static const _demoNotes = {
    6: {1, 8},
    7: {1},
    10: {2, 7},
    11: {2, 7},
    13: {3, 4, 6},
    15: {6, 9},
    20: {4, 7, 9},
    23: {2, 5, 8},
    24: {5},
    26: {5},
    30: {1, 2, 4, 6},
    33: {1, 2, 3, 4},
    38: {2, 6, 8},
    41: {1, 4, 5},
    44: {3, 8},
    48: {1, 6, 8},
    51: {2, 4, 7},
    55: {3, 5, 6, 7},
    58: {2, 4},
    60: {1, 2, 5},
    63: {4, 7, 9},
    66: {1, 2, 5, 8},
    69: {2, 6, 9},
    72: {2, 4, 5},
    76: {1, 5, 6},
  };
  static const _selectedCell = 21;
  static const _activeDigit = 3;
  static const _errorCell = 37;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final mq = MediaQuery.sizeOf(context);
    final double gridSize = (mq.width - 16).clamp(0.0, 520.0);
    final cellSize = gridSize / 9;

    final values = List<int>.filled(81, 0);
    for (int i = 0; i < 81; i++) {
      values[i] = _demoPuzzle.given.valueAt(i);
    }
    _demoUserValues.forEach((index, value) => values[index] = value);

    final noteSets = List<Set<int>>.generate(81, (_) => <int>{});
    _demoNotes.forEach((index, notes) => noteSets[index] = Set.of(notes));

    final counts = <int, int>{};
    for (final v in values) {
      if (v != 0) counts[v] = (counts[v] ?? 0) + 1;
    }

    Widget buildCell(int index) {
      final value = values[index];
      return SudokuCell(
        index: index,
        size: cellSize,
        value: value,
        notes: noteSets[index],
        isGiven: _demoPuzzle.isGivenAt(index),
        isSelected: index == _selectedCell,
        isError: index == _errorCell,
        isSameDigit:
            settings.highlightSameDigits && value == _activeDigit && value != 0,
        hasNoteOfSameDigit:
            settings.highlightSameDigits &&
            noteSets[index].contains(_activeDigit),
        maskGivenCells: settings.maskGivenCells,
        notesLayout: settings.notesLayout,
        removeAnimations: settings.removeAnimations,
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

    final digitButtons = [
      for (int i = 1; i <= 9; i++)
        DigitButton(
          digit: '$i',
          active: i == _activeDigit,
          count: counts[i] ?? 0,
          showCount: settings.showRemainingCounts,
          onTap: () {},
        ),
      const DigitButton(
        digit: 'X',
        active: false,
        count: 9,
        showCount: false,
        onTap: _noop,
      ),
    ];

    final digitPad = Padding(
      padding: const .symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: .min,
        children: [
          Wrap(spacing: 6, children: digitButtons.sublist(0, 5)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: digitButtons.sublist(5)),
        ],
      ),
    );

    const actionRow = Row(
      spacing: 6,
      mainAxisAlignment: .spaceEvenly,
      children: [
        _PreviewActionButton(icon: Icons.refresh_rounded),
        _PreviewActionButton(icon: Icons.lightbulb_outline_rounded),
        _PreviewActionButton(icon: Icons.edit_outlined, active: true),
        _PreviewActionButton(icon: Icons.undo_rounded),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: .expand,
          children: [
            GameLayout(
              gridTopSpacingFraction: gridTopSpacingFraction,
              grid: grid,
              digitPad: digitPad,
              actionRow: actionRow,
            ),
            Align(
              alignment: .topCenter,
              child: AppBar(
                title: const Text('Preview'),
                centerTitle: true,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}

class _PreviewActionButton extends StatelessWidget {
  const new({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active ? scheme.primary : Colors.transparent,
        borderRadius: .circular(6),
      ),
      child: Icon(
        icon,
        color: active ? scheme.surface : scheme.onSurface,
        size: 26,
      ),
    );
  }
}
