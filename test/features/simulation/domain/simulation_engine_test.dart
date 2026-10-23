import 'dart:math';

import 'package:ecobalance/features/simulation/domain/engine/simulation_engine.dart';
import 'package:ecobalance/features/simulation/domain/entities/animal.dart';
import 'package:ecobalance/features/simulation/domain/entities/dna.dart';
import 'package:ecobalance/features/simulation/domain/entities/grass.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:flutter_test/flutter_test.dart';

// no grass growing on its own, so the tests control everything
const testConfig = SimulationConfig(grassGrowthRate: 0);

SimulationEngine emptyWorld() {
  final engine = SimulationEngine(config: testConfig, random: Random(1));
  engine.animals.clear();
  engine.grass = Grass(
    columns: engine.grass.columns,
    rows: engine.grass.rows,
    cellSize: engine.grass.cellSize,
  );
  return engine;
}

Animal rabbit({double x = 100, double y = 100, double energy = 50}) {
  return Animal(
    id: 1,
    species: Species.rabbit,
    dna: const Dna(speed: 1, senseRadius: 40, size: 1),
    x: x,
    y: y,
    energy: energy,
  );
}

Animal fox({double x = 100, double y = 100, double energy = 50}) {
  return Animal(
    id: 2,
    species: Species.fox,
    dna: const Dna(speed: 1, senseRadius: 60, size: 1),
    x: x,
    y: y,
    energy: energy,
  );
}

void main() {
  group('reset', () {
    test('spawns the starting animals from the config', () {
      final engine = SimulationEngine(
        config: const SimulationConfig(startRabbits: 12, startFoxes: 3),
        random: Random(1),
      );

      expect(engine.rabbits.length, 12);
      expect(engine.foxes.length, 3);
      expect(engine.tick, 0);
      expect(engine.history.length, 1);
    });

    test('uses the new config when one is passed', () {
      final engine = SimulationEngine(config: testConfig, random: Random(1));

      engine.reset(const SimulationConfig(startRabbits: 5, startFoxes: 1));

      expect(engine.rabbits.length, 5);
      expect(engine.foxes.length, 1);
    });
  });

  test('same seed gives the same world', () {
    final a = SimulationEngine(config: testConfig, random: Random(42));
    final b = SimulationEngine(config: testConfig, random: Random(42));

    for (var i = 0; i < 300; i++) {
      a.step();
      b.step();
    }

    expect(a.history, b.history);
  });

  group('eating', () {
    test('a rabbit eats the grass it stands on', () {
      final engine = emptyWorld();
      final bunny = rabbit(x: 105, y: 105);
      engine.animals.add(bunny);
      engine.grass.grow(5, 5);

      engine.step();

      expect(engine.grass.isGrown(5, 5), isFalse);
      // it gained grass energy and burned a little
      expect(bunny.energy, greaterThan(50 + SimulationEngine.grassEnergy - 1));
    });

    test('a fox eats a rabbit it touches and then rests', () {
      final engine = emptyWorld();
      final hunter = fox(x: 100, y: 100);
      final bunny = rabbit(x: 105, y: 100);
      engine.animals.addAll([hunter, bunny]);

      engine.step();

      expect(engine.rabbits, isEmpty);
      expect(hunter.energy, greaterThan(50));
      expect(hunter.restTicks, SimulationEngine.foxRestTicks);
    });

    test('a rabbit runs away from a fox it can see', () {
      final engine = emptyWorld();
      final hunter = fox(x: 100, y: 100);
      final bunny = rabbit(x: 120, y: 100);
      // the fox is busy so it does not chase
      hunter.restTicks = 10;
      engine.animals.addAll([hunter, bunny]);

      engine.step();

      expect(bunny.x, greaterThan(120));
    });
  });

  group('reproduction', () {
    test('an adult with enough energy has a baby', () {
      final engine = emptyWorld();
      final parent = rabbit(energy: 100)..age = 1000;
      engine.animals.add(parent);

      engine.step();

      expect(engine.rabbits.length, 2);
      final baby = engine.rabbits.last;
      expect(parent.energy, closeTo(baby.energy, 0.001));
      expect(parent.energy, lessThan(55));
    });

    test('a young animal can not have a baby yet', () {
      final engine = emptyWorld();
      engine.animals.add(rabbit(energy: 100));

      engine.step();

      expect(engine.rabbits.length, 1);
    });
  });

  group('death', () {
    test('an animal without energy dies', () {
      final engine = emptyWorld();
      engine.animals.add(rabbit(energy: 0.01));

      engine.step();

      expect(engine.animals, isEmpty);
    });

    test('an old animal dies', () {
      final engine = emptyWorld();
      engine.animals.add(fox()..age = SimulationEngine.foxMaxAge);

      engine.step();

      expect(engine.animals, isEmpty);
    });
  });

  test('energy cost goes up with speed', () {
    final engine = emptyWorld();
    final slow = rabbit();
    final fast = Animal(
      id: 3,
      species: Species.rabbit,
      dna: const Dna(speed: 2, senseRadius: 40, size: 1),
      x: 0,
      y: 0,
      energy: 50,
    );

    expect(engine.energyCost(fast), greaterThan(engine.energyCost(slow)));
  });

  test('planting grass fills a 3x3 patch', () {
    final engine = emptyWorld();

    engine.plantGrass(105, 105);

    expect(engine.grass.grownCount, 9);
    expect(engine.grass.isGrown(4, 4), isTrue);
    expect(engine.grass.isGrown(6, 6), isTrue);
  });

  test('stats are saved once every second', () {
    final engine = SimulationEngine(config: testConfig, random: Random(1));

    for (var i = 0; i < SimulationEngine.ticksPerSecond * 3; i++) {
      engine.step();
    }

    expect(engine.history.length, 4);
    expect(engine.history.last.second, 3);
  });
}
