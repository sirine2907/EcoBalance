import 'package:equatable/equatable.dart';

/// Everything the user can change in the settings screen.
class SimulationConfig extends Equatable {
  // The world is always the same size, the canvas scales it.
  static const double worldWidth = 800;
  static const double worldHeight = 500;
  static const double cellSize = 20;

  final int startRabbits;
  final int startFoxes;

  /// Chance for each bare cell to grow grass on a tick.
  final double grassGrowthRate;

  /// How far a gene can move when a baby is born (0.1 = 10% of its range).
  final double mutationRate;

  /// Multiplies how much energy rabbits burn every tick.
  final double rabbitEnergyCost;

  /// Multiplies how much energy foxes burn every tick.
  final double foxEnergyCost;

  const SimulationConfig({
    this.startRabbits = 40,
    this.startFoxes = 6,
    this.grassGrowthRate = 0.0015,
    this.mutationRate = 0.1,
    this.rabbitEnergyCost = 1.0,
    this.foxEnergyCost = 1.0,
  });

  SimulationConfig copyWith({
    int? startRabbits,
    int? startFoxes,
    double? grassGrowthRate,
    double? mutationRate,
    double? rabbitEnergyCost,
    double? foxEnergyCost,
  }) {
    return SimulationConfig(
      startRabbits: startRabbits ?? this.startRabbits,
      startFoxes: startFoxes ?? this.startFoxes,
      grassGrowthRate: grassGrowthRate ?? this.grassGrowthRate,
      mutationRate: mutationRate ?? this.mutationRate,
      rabbitEnergyCost: rabbitEnergyCost ?? this.rabbitEnergyCost,
      foxEnergyCost: foxEnergyCost ?? this.foxEnergyCost,
    );
  }

  @override
  List<Object> get props => [
        startRabbits,
        startFoxes,
        grassGrowthRate,
        mutationRate,
        rabbitEnergyCost,
        foxEnergyCost,
      ];
}
