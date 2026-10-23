import 'package:ecobalance/features/simulation/domain/entities/grass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Grass grass;

  setUp(() {
    grass = Grass(columns: 4, rows: 3, cellSize: 10);
  });

  test('starts bare', () {
    expect(grass.cellCount, 12);
    expect(grass.grownCount, 0);
    expect(grass.coverage, 0);
  });

  test('grow and eat a cell', () {
    grass.grow(1, 2);
    expect(grass.isGrown(1, 2), isTrue);
    expect(grass.grownCount, 1);

    grass.eat(1, 2);
    expect(grass.isGrown(1, 2), isFalse);
  });

  test('coverage is the grown part of the grid', () {
    for (var i = 0; i < 6; i++) {
      grass.growAt(i);
    }

    expect(grass.coverage, 0.5);
  });

  test('positions are turned into cells and stay inside the grid', () {
    expect(grass.columnOf(25), 2);
    expect(grass.rowOf(5), 0);
    expect(grass.columnOf(-3), 0);
    expect(grass.columnOf(999), 3);
    expect(grass.rowOf(999), 2);
  });
}
