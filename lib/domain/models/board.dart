import 'package:sudoku/domain/models/cell.dart';

class Board {
  final List<int> cells;
  const Board(this.cells) : assert(cells.length == 81);

  static final empty = Board(List.filled(81, 0));

  int atCell(Cell cell) => cells[cell.index];

  int atIndex(int index) => cells[index];

  int operator [](Cell cell) => atCell(cell);

  Board setCell(Cell cell, int value) {
    final newCells = List<int>.from(cells);
    newCells[cell.index] = value;
    return Board(newCells);
  }

  Board setIndex(int index, int value) {
    final newCells = List<int>.from(cells);
    newCells[index] = value;
    return Board(newCells);
  }

  List<Cell> rowCells(int row) => List.generate(9, (col) => Cell(row, col));

  List<Cell> colCells(int col) => List.generate(9, (row) => Cell(row, col));

  List<Cell> boxCells(int boxRow, int boxCol) {
    final startR = boxRow * 3, startC = boxCol * 3;
    return [
      for (var r = startR; r < startR + 3; r++)
        for (var c = startC; c < startC + 3; c++) Cell(r, c),
    ];
  }

  List<int> valuesOfRow(Cell cell) => rowCells(cell.row).map(atCell).toList();

  List<int> valuesOfCol(Cell cell) => colCells(cell.col).map(atCell).toList();

  List<int> valuesOfBox(Cell cell) =>
      boxCells(cell.row ~/ 3, cell.col ~/ 3).map(atCell).toList();

  static final List<Cell> allCells = [
    for (int i = 0; i < 81; i++) Cell.fromIndex(i),
  ];

  factory Board.fromRows(List<List<int>> rows) {
    final cells = rows.expand((row) => row).toList();
    return Board(cells);
  }

  List<List<int>> toRows() =>
      List.generate(9, (r) => List.generate(9, (c) => atCell(Cell(r, c))));

  bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Board && _listEquals(cells, other.cells);

  @override
  int get hashCode => Object.hashAll(cells);

  @override
  String toString() {
    final buffer = StringBuffer();
    for (int row = 0; row < 9; row++) {
      if (row % 3 == 0 && row != 0) {
        buffer.writeln('------+-------+------');
      }
      for (int col = 0; col < 9; col++) {
        if (col % 3 == 0 && col != 0) {
          buffer.write('| ');
        }
        final value = cells[row * 9 + col];
        buffer.write(value == 0 ? '. ' : '$value ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
