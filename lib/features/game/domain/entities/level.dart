import 'package:equatable/equatable.dart';

import '../../../simulation/domain/entities/simulation_config.dart';

/// One level of the game mode: a world, a time limit and some seeds.
class Level extends Equatable {
  final int number;
  final String name;
  final String description;
  final SimulationConfig config;

  /// Keep both species alive this long to win.
  final int durationSeconds;

  /// How many times the player can plant grass.
  final int seeds;

  const Level({
    required this.number,
    required this.name,
    required this.description,
    required this.config,
    required this.durationSeconds,
    required this.seeds,
  });

  /// Using this many seeds or less gives a star.
  int get seedGoal => seeds ~/ 2;

  @override
  List<Object> get props =>
      [number, name, description, config, durationSeconds, seeds];
}
