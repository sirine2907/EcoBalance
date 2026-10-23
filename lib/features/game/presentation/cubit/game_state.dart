import 'package:equatable/equatable.dart';

import '../../domain/entities/level.dart';
import '../../domain/game_rules.dart';

class GameState extends Equatable {
  final Level level;
  final GameStatus status;
  final int seedsLeft;
  final int secondsLeft;

  /// Filled in when the game is won.
  final int stars;
  final int score;

  /// True when the rabbits died out, false when it was the foxes.
  final bool rabbitsDied;

  const GameState({
    required this.level,
    required this.status,
    required this.seedsLeft,
    required this.secondsLeft,
    this.stars = 0,
    this.score = 0,
    this.rabbitsDied = false,
  });

  int get seedsUsed => level.seeds - seedsLeft;

  bool get isOver => status != GameStatus.playing;

  GameState copyWith({
    GameStatus? status,
    int? seedsLeft,
    int? secondsLeft,
    int? stars,
    int? score,
    bool? rabbitsDied,
  }) {
    return GameState(
      level: level,
      status: status ?? this.status,
      seedsLeft: seedsLeft ?? this.seedsLeft,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      stars: stars ?? this.stars,
      score: score ?? this.score,
      rabbitsDied: rabbitsDied ?? this.rabbitsDied,
    );
  }

  @override
  List<Object> get props =>
      [level, status, seedsLeft, secondsLeft, stars, score, rabbitsDied];
}
