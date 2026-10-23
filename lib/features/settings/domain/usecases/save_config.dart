import '../../../simulation/domain/entities/simulation_config.dart';
import '../repositories/settings_repository.dart';

class SaveConfig {
  final SettingsRepository repository;

  SaveConfig(this.repository);

  Future<void> call(SimulationConfig config) => repository.saveConfig(config);
}
