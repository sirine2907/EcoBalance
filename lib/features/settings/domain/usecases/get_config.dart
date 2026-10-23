import '../../../simulation/domain/entities/simulation_config.dart';
import '../repositories/settings_repository.dart';

class GetConfig {
  final SettingsRepository repository;

  GetConfig(this.repository);

  Future<SimulationConfig> call() => repository.getConfig();
}
