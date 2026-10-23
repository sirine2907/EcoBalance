import 'dart:math';

import 'package:equatable/equatable.dart';

/// The genes of an animal. A child gets a slightly changed copy.
class Dna extends Equatable {
  static const double minSpeed = 0.5;
  static const double maxSpeed = 4.0;
  static const double minSense = 10;
  static const double maxSense = 150;
  static const double minSize = 0.5;
  static const double maxSize = 2.0;

  final double speed;
  final double senseRadius;
  final double size;

  const Dna({
    required this.speed,
    required this.senseRadius,
    required this.size,
  });

  /// Returns a copy where every gene moved a little.
  /// [mutationRate] 0.1 means a gene can move up to 10% of its range.
  Dna mutate(Random random, double mutationRate) {
    return Dna(
      speed: _mutateGene(random, speed, minSpeed, maxSpeed, mutationRate),
      senseRadius:
          _mutateGene(random, senseRadius, minSense, maxSense, mutationRate),
      size: _mutateGene(random, size, minSize, maxSize, mutationRate),
    );
  }

  double _mutateGene(
    Random random,
    double value,
    double min,
    double max,
    double mutationRate,
  ) {
    // random number between -1 and 1
    final change = (random.nextDouble() * 2 - 1) * mutationRate * (max - min);
    return (value + change).clamp(min, max);
  }

  @override
  List<Object> get props => [speed, senseRadius, size];
}
