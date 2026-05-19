import 'package:flutter/material.dart';

/// A mini 3-row grid used to display pencil candidates (notes) inside a cell.
///
/// This widget dynamically aligns and formats the candidate notes based on the
/// total count to prevent overlapping and maintain a clean grid visual. It
/// divides candidates into up to three rows (top, middle, bottom) and scales
/// font size proportionally based on the cell size.
class NotesGrid extends StatelessWidget {
  /// Creates a notes grid to render candidates inside a cell.
  const NotesGrid({required this.notes, required this.cellSize, super.key});

  /// The set of pencil notes/candidates active inside this cell.
  final Set<int> notes;

  /// The size (width and height) of the parent cell container.
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;
    final fontSize = cellSize * 0.21;

    final notesList = notes.toList()..sort();
    final n = notesList.length;

    var middleCount = 0;
    var topCount = 0;

    if (n == 3) {
      middleCount = 1;
    } else if (n == 4) {
      middleCount = 2;
    } else if (n == 5) {
      middleCount = 3;
    } else if (n == 6) {
      middleCount = 4;
    } else if (n == 7) {
      middleCount = 4;
      topCount = 1;
    } else if (n >= 8) {
      middleCount = 4;
      topCount = n - 6;
    }

    final topRow = notesList.sublist(0, topCount);
    final middleRow = notesList.sublist(topCount, topCount + middleCount);
    final bottomRow = notesList.sublist(topCount + middleCount);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topRow.isNotEmpty) ...[
          _buildRow(topRow, fontSize, color),
          const SizedBox(height: 1),
        ],
        if (middleRow.isNotEmpty) ...[
          _buildRow(middleRow, fontSize, color),
          const SizedBox(height: 1),
        ],
        if (bottomRow.isNotEmpty) _buildRow(bottomRow, fontSize, color),
      ],
    );
  }

  Widget _buildRow(List<int> digits, double fontSize, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: digits
          .map(
            (digit) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
