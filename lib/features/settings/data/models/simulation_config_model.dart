import '../../../simulation/domain/entities/simulation_config.dart';

/// Turns the config into json so we can save it.
class SimulationConfigModel {
  static Map<String, dynamic> toJson(SimulationConfig config) {
    return {
      'startRabbits': config.startRabbits,
      'startFoxes': config.startFoxes,
      'grassGrowthRate': config.grassGrowthRate,
      'mutationRate': config.mutationRate,
      'rabbitEnergyCost': config.rabbitEnergyCost,
      'foxEnergyCost': config.foxEnergyCost,
    };
  }

  /// Missing values fall back to the defaults.
  static SimulationConfig fromJson(Map<String, dynamic> json) {
    const defaults = SimulationConfig();
    return SimulationConfig(
      startRabbits: json['startRabbits'] as int? ?? defaults.startRabbits,
      startFoxes: json['startFoxes'] as int? ?? defaults.startFoxes,
      grassGrowthRate: (json['grassGrowthRate'] as num?)?.toDouble() ??
          defaults.grassGrowthRate,
      mutationRate:
          (json['mutationRate'] as num?)?.toDouble() ?? defaults.mutationRate,
      rabbitEnergyCost: (json['rabbitEnergyCost'] as num?)?.toDouble() ??
          defaults.rabbitEnergyCost,
      foxEnergyCost:
          (json['foxEnergyCost'] as num?)?.toDouble() ?? defaults.foxEnergyCost,
    );
  }
}
