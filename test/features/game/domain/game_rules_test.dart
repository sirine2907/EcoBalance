import 'package:ecobalance/features/game/domain/entities/level.dart';
import 'package:ecobalance/features/game/domain/game_rules.dart';
import 'package:ecobalance/features/game/domain/levels.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:flutter_test/flutter_test.dart';

const level = Level(
  number: 1,
  name: 'Test',
  description: 'A test level',
  config: SimulationConfig(),
  durationSeconds: 60,
  seeds: 10,
);

void main() {
  group('check', () {
    test('playing while both species are alive and time is left', () {
      final status =
          GameRules.check(level: level, second: 30, rabbits: 10, foxes: 2);

      expect(status, GameStatus.playing);
    });

    test('lost when the rabbits die out', () {
      final status =
          GameRules.check(level: level, second: 30, rabbits: 0, foxes: 5);

      expect(status, GameStatus.lost);
    });

    test('lost when the foxes die out', () {
      final status =
          GameRules.check(level: level, second: 30, rabbits: 50, foxes: 0);

      expect(status, GameStatus.lost);
    });

    test('won when the time is over', () {
      final status =
          GameRules.check(level: level, second: 60, rabbits: 3, foxes: 1);

      expect(status, GameStatus.won);
    });

    test('dying out on the last second is still a loss', () {
      final status =
          GameRules.check(level: level, second: 60, rabbits: 0, foxes: 4);

      expect(status, GameStatus.lost);
    });
  });

  group('stars', () {
    test('one star for just surviving', () {
      final stars =
          GameRules.stars(level: level, seedsUsed: 8, rabbits: 5, foxes: 1);

      expect(stars, 1);
    });

    test('a star for using half the seeds or less', () {
      final stars =
          GameRules.stars(level: level, seedsUsed: 5, rabbits: 5, foxes: 1);

      expect(stars, 2);
    });

    test('three stars with few seeds and a healthy world', () {
      final stars =
          GameRules.stars(level: level, seedsUsed: 0, rabbits: 30, foxes: 5);

      expect(stars, 3);
    });
  });

  test('score goes up with seeds left and animals', () {
    final low = GameRules.score(seedsLeft: 0, rabbits: 10, foxes: 2);
    final high = GameRules.score(seedsLeft: 5, rabbits: 60, foxes: 10);

    expect(low, 1000 + 50 + 40);
    expect(high, greaterThan(low));
  });

  test('levels are numbered 1 to 5 in order', () {
    expect(levels.map((l) => l.number), [1, 2, 3, 4, 5]);
  });
}
