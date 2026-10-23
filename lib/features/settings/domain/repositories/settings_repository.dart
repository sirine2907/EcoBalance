import '../../../simulation/domain/entities/simulation_config.dart';

abstract class SettingsRepository {
  Future<SimulationConfig> getConfig();

  Future<void> saveConfig(SimulationConfig config);
}
