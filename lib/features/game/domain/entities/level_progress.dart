import 'package:equatable/equatable.dart';

/// The best result the player got on a level.
class LevelProgress extends Equatable {
  final int stars;
  final int bestScore;

  const LevelProgress({required this.stars, required this.bestScore});

  bool get isCleared => stars > 0;

  @override
  List<Object> get props => [stars, bestScore];
}
