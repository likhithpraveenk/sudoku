class Cell {
  final int row;
  final int col;
  const Cell(this.row, this.col)
    : assert(row >= 0 && row < 9),
      assert(col >= 0 && col < 9);

  int get index => row * 9 + col;

  factory Cell.fromIndex(int index) => Cell(index ~/ 9, index % 9);

  @override
  bool operator ==(Object other) =>
      other is Cell && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Cell($row,$col)';
}
