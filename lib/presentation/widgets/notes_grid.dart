import 'package:flutter/material.dart';

class NotesGrid extends StatelessWidget {
  const NotesGrid({
    required this.notes,
    required this.cellSize,
    super.key,
    this.hasNoteOfSameDigit = false,
  });

  final Set<int> notes;

  final double cellSize;

  final bool hasNoteOfSameDigit;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    final color = hasNoteOfSameDigit ? cs.surface : cs.onSurface;

    final fontSize = cellSize * 0.2;

    final digits = notes.toList()..sort();

    final (top, middle, bottom) = _splitRows(digits);

    return Column(
      mainAxisSize: .min,
      mainAxisAlignment: .end,
      children: [
        if (top.isNotEmpty) ...[
          _NotesRow(digits: top, fontSize: fontSize, color: color),
          const SizedBox(height: 1),
        ],
        if (middle.isNotEmpty) ...[
          _NotesRow(digits: middle, fontSize: fontSize, color: color),
          const SizedBox(height: 1),
        ],
        if (bottom.isNotEmpty)
          _NotesRow(digits: bottom, fontSize: fontSize, color: color),
      ],
    );
  }

  (List<int>, List<int>, List<int>) _splitRows(List<int> digits) {
    final n = digits.length;

    final (topCount, middleCount) = switch (n) {
      <= 2 => (0, 0),
      3 => (0, 1),
      4 => (0, 2),
      5 => (0, 3),
      6 => (0, 4),
      7 => (1, 4),
      _ => (n - 6, 4),
    };

    final top = digits.sublist(0, topCount);

    final middle = digits.sublist(topCount, topCount + middleCount);

    final bottom = digits.sublist(topCount + middleCount);

    return (top, middle, bottom);
  }
}

class _NotesRow extends StatelessWidget {
  const _NotesRow({
    required this.digits,
    required this.fontSize,
    required this.color,
  });

  final List<int> digits;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final digit in digits)
          Padding(
            padding: const .symmetric(horizontal: 0.8),
            child: Text(
              '$digit',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: .w500,
                height: 1,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
