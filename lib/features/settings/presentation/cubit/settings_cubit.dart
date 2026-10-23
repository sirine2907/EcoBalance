import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../simulation/domain/entities/simulation_config.dart';
import '../../domain/usecases/save_config.dart';

/// Holds the current settings and saves them when they change.
class SettingsCubit extends Cubit<SimulationConfig> {
  final SaveConfig saveConfig;

  SettingsCubit({
    required this.saveConfig,
    SimulationConfig initialConfig = const SimulationConfig(),
  }) : super(initialConfig);

  Future<void> update(SimulationConfig config) async {
    emit(config);
    await saveConfig(config);
  }

  Future<void> resetToDefaults() => update(const SimulationConfig());
}
