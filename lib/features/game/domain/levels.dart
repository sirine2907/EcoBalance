import '../../simulation/domain/entities/simulation_config.dart';
import 'entities/level.dart';

/// All the levels, from easy to hard.
const levels = [
  Level(
    number: 1,
    name: 'First Spring',
    description: 'A calm world to learn the basics.',
    config: SimulationConfig(),
    durationSeconds: 60,
    seeds: 10,
  ),
  Level(
    number: 2,
    name: 'Hungry Foxes',
    description: 'Twice as many foxes and fewer rabbits.',
    config: SimulationConfig(startRabbits: 25, startFoxes: 12),
    durationSeconds: 90,
    seeds: 8,
  ),
  Level(
    number: 3,
    name: 'Wild Mutations',
    description: 'Babies change a lot. Foxes need less food.',
    config: SimulationConfig(
      mutationRate: 0.35,
      foxEnergyCost: 0.8,
      startFoxes: 10,
    ),
    durationSeconds: 120,
    seeds: 8,
  ),
  Level(
    number: 4,
    name: 'Dry Season',
    description: 'Grass grows back very slowly.',
    config: SimulationConfig(grassGrowthRate: 0.0007, startRabbits: 30),
    durationSeconds: 90,
    seeds: 12,
  ),
  Level(
    number: 5,
    name: 'Last Stand',
    description: 'Few rabbits, many foxes, little grass.',
    config: SimulationConfig(
      startRabbits: 20,
      startFoxes: 12,
      grassGrowthRate: 0.0009,
      rabbitEnergyCost: 1.2,
    ),
    durationSeconds: 150,
    seeds: 10,
  ),
];
