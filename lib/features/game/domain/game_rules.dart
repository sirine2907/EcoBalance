import 'entities/level.dart';

enum GameStatus { playing, won, lost }

/// The win/lose rules, stars and score. Plain functions so they are
/// easy to test.
class GameRules {
  // a "healthy" world at the end gives the third star
  static const int healthyRabbits = 30;
  static const int healthyFoxes = 5;

  static GameStatus check({
    required Level level,
    required int second,
    required int rabbits,
    required int foxes,
  }) {
    if (rabbits == 0 || foxes == 0) return GameStatus.lost;
    if (second >= level.durationSeconds) return GameStatus.won;
    return GameStatus.playing;
  }

  static bool isHealthy(int rabbits, int foxes) {
    return rabbits >= healthyRabbits && foxes >= healthyFoxes;
  }

  /// One star for winning, one for saving seeds, one for a healthy world.
  static int stars({
    required Level level,
    required int seedsUsed,
    required int rabbits,
    required int foxes,
  }) {
    var stars = 1;
    if (seedsUsed <= level.seedGoal) stars++;
    if (isHealthy(rabbits, foxes)) stars++;
    return stars;
  }

  /// Only a win gets points. Seeds left and a big world give more.
  static int score({
    required int seedsLeft,
    required int rabbits,
    required int foxes,
  }) {
    return 1000 + seedsLeft * 100 + rabbits * 5 + foxes * 20;
  }
}
