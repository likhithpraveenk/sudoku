/// The [kGridPeers] field.
final List<List<int>> kGridPeers = List.generate(81, (i) {
  final row = i ~/ 9;
  final col = i % 9;
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  final peers = <int>{};
  for (var x = 0; x < 9; x++) {
    peers
      ..add(row * 9 + x) // row peer
      ..add(x * 9 + col); // col peer
  }
  for (var dr = 0; dr < 3; dr++) {
    for (var dc = 0; dc < 3; dc++) {
      peers.add((boxRow + dr) * 9 + (boxCol + dc));
    }
  }
  peers.remove(i);
  return peers.toList();
});

/// The [isPeer] method.
bool isPeer(int a, int b) {
  if (a == b) return false;
  final rowA = a ~/ 9;
  final colA = a % 9;
  final rowB = b ~/ 9;
  final colB = b % 9;
  final sameRow = rowA == rowB;
  final sameCol = colA == colB;
  final sameBox = (rowA ~/ 3 == rowB ~/ 3) && (colA ~/ 3 == colB ~/ 3);
  return sameRow || sameCol || sameBox;
}

/// A public member.
Set<int> peersOf(int index) => kGridPeerSets[index];

/// The [kGridPeerSets] field.
final List<Set<int>> kGridPeerSets = kGridPeers.map((l) => l.toSet()).toList();

/// A public member.
List<Set<int>> buildCandidates(List<int> cells) {
  return List.generate(81, (i) {
    if (cells[i] != 0) return <int>{};
    final used = <int>{};
    for (final p in kGridPeers[i]) {
      if (cells[p] != 0) used.add(cells[p]);
    }
    return {1, 2, 3, 4, 5, 6, 7, 8, 9}..removeAll(used);
  });
}

/// The [kGridUnits] field.
final List<List<int>> kGridUnits = () {
  final units = <List<int>>[];

  // 9 row units
  for (var row = 0; row < 9; row++) {
    units.add(List.generate(9, (col) => row * 9 + col));
  }
  // 9 col units
  for (var col = 0; col < 9; col++) {
    units.add(List.generate(9, (row) => row * 9 + col));
  }

  // 9 box units
  for (var boxRow = 0; boxRow < 3; boxRow++) {
    for (var boxCol = 0; boxCol < 3; boxCol++) {
      final boxCells = <int>[];
      for (var row = boxRow * 3; row < boxRow * 3 + 3; row++) {
        for (var col = boxCol * 3; col < boxCol * 3 + 3; col++) {
          boxCells.add(row * 9 + col);
        }
      }
      units.add(boxCells);
    }
  }
  return units;
}();

/// The [isSolved] method.
bool isSolved(List<int> cells) => !cells.contains(0);

/// The [isValid] method.
bool isValid(List<int> cells, int index, int digit) {
  final row = index ~/ 9;
  final col = index % 9;
  for (var i = 0; i < 9; i++) {
    if (i != col && cells[row * 9 + i] == digit) return false;
    if (i != row && cells[i * 9 + col] == digit) return false;
  }
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  for (var dr = 0; dr < 3; dr++) {
    for (var dc = 0; dc < 3; dc++) {
      final nr = boxRow + dr;
      final nc = boxCol + dc;
      if (nr == row && nc == col) continue;
      if (cells[nr * 9 + nc] == digit) return false;
    }
  }
  return true;
}

/// The [kGridRows] field.
final List<int> kGridRows = List.generate(81, (i) => i ~/ 9);

/// The [kGridCols] field.
final List<int> kGridCols = List.generate(81, (i) => i % 9);

/// The [kGridBoxes] field.
final List<int> kGridBoxes = List.generate(
  81,
  (i) => (i ~/ 27) * 3 + (i % 9) ~/ 3,
);

/// The [getRow] method.
int getRow(int index) => kGridRows[index];

/// The [getCol] method.
int getCol(int index) => kGridCols[index];

/// The [getBox] method.
int getBox(int index) => kGridBoxes[index];

/// A public member.
List<int> getRowUnit(int row) => kGridUnits[row];

/// A public member.
List<int> getColUnit(int col) => kGridUnits[9 + col];

/// A public member.
List<int> getBoxUnit(int box) => kGridUnits[18 + box];

/// A public member.
List<List<int>> getUnitsOf(int index) => [
  getRowUnit(getRow(index)),
  getColUnit(getCol(index)),
  getBoxUnit(getBox(index)),
];
