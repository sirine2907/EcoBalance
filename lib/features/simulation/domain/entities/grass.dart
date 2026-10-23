/// The ground of the world, split into square cells.
/// Every cell either has grass on it or is bare.
class Grass {
  final int columns;
  final int rows;
  final double cellSize;
  final List<bool> _cells;

  Grass({
    required this.columns,
    required this.rows,
    required this.cellSize,
    bool startGrown = false,
  }) : _cells = List.filled(columns * rows, startGrown);

  int get cellCount => _cells.length;

  int get grownCount => _cells.where((cell) => cell).length;

  /// How much of the world is covered, from 0 to 1.
  double get coverage => grownCount / cellCount;

  bool isGrown(int column, int row) => _cells[_index(column, row)];

  void grow(int column, int row) => _cells[_index(column, row)] = true;

  void eat(int column, int row) => _cells[_index(column, row)] = false;

  bool isGrownAt(int index) => _cells[index];

  void growAt(int index) => _cells[index] = true;

  int columnOf(double x) => (x / cellSize).floor().clamp(0, columns - 1);

  int rowOf(double y) => (y / cellSize).floor().clamp(0, rows - 1);

  int _index(int column, int row) => row * columns + column;
}
