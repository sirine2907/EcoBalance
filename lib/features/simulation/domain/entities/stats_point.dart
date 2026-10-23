import 'package:equatable/equatable.dart';

/// A snapshot of the world, saved once every simulated second.
class StatsPoint extends Equatable {
  final int second;
  final int rabbits;
  final int foxes;

  /// Percent of the world covered with grass (0 - 100).
  final double grass;

  final double avgRabbitSpeed;
  final double avgRabbitSense;
  final double avgRabbitSize;
  final double avgFoxSpeed;
  final double avgFoxSense;
  final double avgFoxSize;

  const StatsPoint({
    required this.second,
    required this.rabbits,
    required this.foxes,
    required this.grass,
    required this.avgRabbitSpeed,
    required this.avgRabbitSense,
    required this.avgRabbitSize,
    required this.avgFoxSpeed,
    required this.avgFoxSense,
    required this.avgFoxSize,
  });

  @override
  List<Object> get props => [
        second,
        rabbits,
        foxes,
        grass,
        avgRabbitSpeed,
        avgRabbitSense,
        avgRabbitSize,
        avgFoxSpeed,
        avgFoxSense,
        avgFoxSize,
      ];
}
