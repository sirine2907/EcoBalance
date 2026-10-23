import 'dart:math';

import '../entities/animal.dart';
import '../entities/dna.dart';
import '../entities/grass.dart';
import '../entities/simulation_config.dart';
import '../entities/stats_point.dart';

/// Runs the world one tick at a time. Pure Dart, no Flutter,
/// so it is easy to test with a seeded [Random].
class SimulationEngine {
  static const int ticksPerSecond = 30;
  static const int maxRabbits = 300;
  static const int maxFoxes = 20;

  /// Foxes run a bit faster when they chase a rabbit.
  static const double foxSprint = 1.3;

  /// How long a fox rests after eating a rabbit.
  static const int foxRestTicks = ticksPerSecond * 3;

  /// Rabbits see foxes only in this part of their sense radius.
  static const double foxSpotRange = 0.6;

  static const double grassEnergy = 20;

  /// Animals have a baby when their energy goes over this part of the max.
  static const double reproduceThreshold = 0.8;
  static const int adultAge = 60;
  static const int rabbitMaxAge = ticksPerSecond * 60;
  static const int foxMaxAge = ticksPerSecond * 90;

  static const Dna startRabbitDna = Dna(speed: 1.5, senseRadius: 40, size: 1);
  static const Dna startFoxDna = Dna(speed: 2, senseRadius: 60, size: 1.2);

  final Random _random;
  SimulationConfig _config;

  final List<Animal> animals = [];
  final List<StatsPoint> history = [];
  late Grass grass;
  int tick = 0;
  int _nextId = 0;

  SimulationEngine({required SimulationConfig config, Random? random})
      : _config = config,
        _random = random ?? Random() {
    reset();
  }

  SimulationConfig get config => _config;

  int get second => tick ~/ ticksPerSecond;

  List<Animal> get rabbits => animals.where((a) => a.isRabbit).toList();

  List<Animal> get foxes => animals.where((a) => a.isFox).toList();

  /// Starts a new world. Pass [newConfig] to use new settings.
  void reset([SimulationConfig? newConfig]) {
    if (newConfig != null) _config = newConfig;

    tick = 0;
    _nextId = 0;
    animals.clear();
    history.clear();

    grass = Grass(
      columns: (SimulationConfig.worldWidth / SimulationConfig.cellSize).round(),
      rows: (SimulationConfig.worldHeight / SimulationConfig.cellSize).round(),
      cellSize: SimulationConfig.cellSize,
    );
    // start with some random grass so rabbits have food
    for (var i = 0; i < grass.cellCount; i++) {
      if (_random.nextDouble() < 0.4) grass.growAt(i);
    }

    for (var i = 0; i < _config.startRabbits; i++) {
      animals.add(_spawn(Species.rabbit, startRabbitDna));
    }
    for (var i = 0; i < _config.startFoxes; i++) {
      animals.add(_spawn(Species.fox, startFoxDna));
    }

    _recordStats();
  }

  /// Moves the world forward by one tick.
  void step() {
    tick++;
    _growGrass();

    for (final animal in animals) {
      if (animal.isDead) continue;

      if (animal.isRabbit) {
        _updateRabbit(animal);
      } else {
        _updateFox(animal);
      }

      animal.energy -= energyCost(animal);
      animal.age++;

      final maxAge = animal.isRabbit ? rabbitMaxAge : foxMaxAge;
      if (animal.energy <= 0 || animal.age > maxAge) {
        animal.isDead = true;
      }
    }

    animals.removeWhere((a) => a.isDead);
    _reproduce();

    if (tick % ticksPerSecond == 0) _recordStats();
  }

  /// Plants grass in a small 3x3 patch around the tapped point.
  void plantGrass(double x, double y) {
    final column = grass.columnOf(x);
    final row = grass.rowOf(y);
    for (var c = column - 1; c <= column + 1; c++) {
      for (var r = row - 1; r <= row + 1; r++) {
        if (c >= 0 && c < grass.columns && r >= 0 && r < grass.rows) {
          grass.grow(c, r);
        }
      }
    }
  }

  /// Fast and big animals burn more energy, good eyes cost a little too.
  double energyCost(Animal animal) {
    final dna = animal.dna;
    final cost = 0.025 * dna.speed * dna.speed +
        0.05 * dna.size +
        0.0015 * dna.senseRadius;
    final multiplier =
        animal.isRabbit ? _config.rabbitEnergyCost : _config.foxEnergyCost;
    return cost * multiplier;
  }

  void _growGrass() {
    for (var i = 0; i < grass.cellCount; i++) {
      if (!grass.isGrownAt(i) && _random.nextDouble() < _config.grassGrowthRate) {
        grass.growAt(i);
      }
    }
  }

  void _updateRabbit(Animal rabbit) {
    // foxes are sneaky, rabbits only notice them when they are close
    final fox = _nearest(
      rabbit,
      foxesOnly: true,
      range: rabbit.dna.senseRadius * foxSpotRange,
    );
    final grassTarget = _nearestGrass(rabbit);

    if (fox != null) {
      // run away from the fox
      rabbit.heading = atan2(rabbit.y - fox.y, rabbit.x - fox.x);
    } else if (grassTarget != null) {
      rabbit.heading =
          atan2(grassTarget.y - rabbit.y, grassTarget.x - rabbit.x);
    } else {
      _wander(rabbit);
    }

    _move(rabbit);

    final column = grass.columnOf(rabbit.x);
    final row = grass.rowOf(rabbit.y);
    if (grass.isGrown(column, row)) {
      grass.eat(column, row);
      rabbit.energy = min(rabbit.energy + grassEnergy, rabbit.maxEnergy);
    }
  }

  void _updateFox(Animal fox) {
    // a fox that just ate takes a little break
    if (fox.restTicks > 0) {
      fox.restTicks--;
      return;
    }

    final rabbit = _nearest(fox, foxesOnly: false, range: fox.dna.senseRadius);

    if (rabbit == null) {
      _wander(fox);
      _move(fox);
      return;
    }

    fox.heading = atan2(rabbit.y - fox.y, rabbit.x - fox.x);
    _move(fox, boost: foxSprint);

    if (_distance(fox, rabbit) < fox.radius + rabbit.radius) {
      rabbit.isDead = true;
      // bigger rabbits are a bigger meal
      fox.energy = min(fox.energy + 80 * rabbit.dna.size, fox.maxEnergy);
      fox.restTicks = foxRestTicks;
    }
  }

  /// Finds the closest fox (for rabbits) or rabbit (for foxes)
  /// within [range].
  Animal? _nearest(
    Animal animal, {
    required bool foxesOnly,
    required double range,
  }) {
    Animal? closest;
    var closestDistance = range;

    for (final other in animals) {
      if (other.isDead || other.isFox != foxesOnly) continue;
      final distance = _distance(animal, other);
      if (distance < closestDistance) {
        closest = other;
        closestDistance = distance;
      }
    }
    return closest;
  }

  /// Center of the closest grass cell inside the sense radius.
  Point<double>? _nearestGrass(Animal rabbit) {
    final cellSize = grass.cellSize;
    final reach = (rabbit.dna.senseRadius / cellSize).ceil();
    final column = grass.columnOf(rabbit.x);
    final row = grass.rowOf(rabbit.y);

    Point<double>? closest;
    var closestDistance = rabbit.dna.senseRadius;

    for (var c = column - reach; c <= column + reach; c++) {
      for (var r = row - reach; r <= row + reach; r++) {
        if (c < 0 || c >= grass.columns || r < 0 || r >= grass.rows) continue;
        if (!grass.isGrown(c, r)) continue;

        final x = (c + 0.5) * cellSize;
        final y = (r + 0.5) * cellSize;
        final distance = sqrt(pow(x - rabbit.x, 2) + pow(y - rabbit.y, 2));
        if (distance < closestDistance) {
          closest = Point(x, y);
          closestDistance = distance;
        }
      }
    }
    return closest;
  }

  void _wander(Animal animal) {
    animal.heading += (_random.nextDouble() - 0.5) * 0.6;
  }

  void _move(Animal animal, {double boost = 1}) {
    final speed = animal.dna.speed * boost;
    animal.x += cos(animal.heading) * speed;
    animal.y += sin(animal.heading) * speed;

    // bounce off the walls
    if (animal.x < 0 || animal.x > SimulationConfig.worldWidth) {
      animal.heading = pi - animal.heading;
      animal.x = animal.x.clamp(0, SimulationConfig.worldWidth);
    }
    if (animal.y < 0 || animal.y > SimulationConfig.worldHeight) {
      animal.heading = -animal.heading;
      animal.y = animal.y.clamp(0, SimulationConfig.worldHeight);
    }
  }

  void _reproduce() {
    var rabbitCount = animals.where((a) => a.isRabbit).length;
    var foxCount = animals.length - rabbitCount;
    final babies = <Animal>[];

    for (final parent in animals) {
      final canHaveBaby = parent.age > adultAge &&
          parent.energy >= parent.maxEnergy * reproduceThreshold;
      if (!canHaveBaby) continue;

      if (parent.isRabbit && rabbitCount >= maxRabbits) continue;
      if (parent.isFox && foxCount >= maxFoxes) continue;

      // the parent gives half of its energy to the baby
      parent.energy /= 2;
      final baby = Animal(
        id: _nextId++,
        species: parent.species,
        dna: parent.dna.mutate(_random, _config.mutationRate),
        x: parent.x,
        y: parent.y,
        energy: parent.energy,
        heading: _random.nextDouble() * 2 * pi,
      );
      babies.add(baby);

      if (parent.isRabbit) {
        rabbitCount++;
      } else {
        foxCount++;
      }
    }

    animals.addAll(babies);
  }

  Animal _spawn(Species species, Dna dna) {
    final animal = Animal(
      id: _nextId++,
      species: species,
      dna: dna.mutate(_random, _config.mutationRate),
      x: _random.nextDouble() * SimulationConfig.worldWidth,
      y: _random.nextDouble() * SimulationConfig.worldHeight,
      energy: 0,
      heading: _random.nextDouble() * 2 * pi,
    );
    animal.energy = animal.maxEnergy / 2;
    return animal;
  }

  void _recordStats() {
    final rabbitList = rabbits;
    final foxList = foxes;

    history.add(StatsPoint(
      second: second,
      rabbits: rabbitList.length,
      foxes: foxList.length,
      grass: grass.coverage * 100,
      avgRabbitSpeed: _average(rabbitList, (dna) => dna.speed),
      avgRabbitSense: _average(rabbitList, (dna) => dna.senseRadius),
      avgRabbitSize: _average(rabbitList, (dna) => dna.size),
      avgFoxSpeed: _average(foxList, (dna) => dna.speed),
      avgFoxSense: _average(foxList, (dna) => dna.senseRadius),
      avgFoxSize: _average(foxList, (dna) => dna.size),
    ));
  }

  double _average(List<Animal> list, double Function(Dna dna) gene) {
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (sum, a) => sum + gene(a.dna));
    return total / list.length;
  }

  double _distance(Animal a, Animal b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }
}
