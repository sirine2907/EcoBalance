import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../simulation/domain/entities/simulation_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/simulation_config_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const configKey = 'simulation_config';

  final SharedPreferences prefs;

  SettingsRepositoryImpl(this.prefs);

  @override
  Future<SimulationConfig> getConfig() async {
    final saved = prefs.getString(configKey);
    if (saved == null) return const SimulationConfig();

    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      return SimulationConfigModel.fromJson(json);
    } on FormatException {
      // broken data, just start with the defaults
      return const SimulationConfig();
    }
  }

  @override
  Future<void> saveConfig(SimulationConfig config) async {
    final json = SimulationConfigModel.toJson(config);
    await prefs.setString(configKey, jsonEncode(json));
  }
}
