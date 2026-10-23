import 'package:ecobalance/features/settings/data/models/simulation_config_model.dart';
import 'package:ecobalance/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const custom = SimulationConfig(
    startRabbits: 80,
    startFoxes: 10,
    grassGrowthRate: 0.003,
    mutationRate: 0.25,
    rabbitEnergyCost: 1.5,
    foxEnergyCost: 0.5,
  );

  group('SimulationConfigModel', () {
    test('json round trip keeps every value', () {
      final json = SimulationConfigModel.toJson(custom);

      expect(SimulationConfigModel.fromJson(json), custom);
    });

    test('missing values use the defaults', () {
      final config = SimulationConfigModel.fromJson({'startFoxes': 2});

      expect(config, const SimulationConfig().copyWith(startFoxes: 2));
    });
  });

  group('SettingsRepositoryImpl', () {
    Future<SettingsRepositoryImpl> createRepository(
      Map<String, Object> saved,
    ) async {
      SharedPreferences.setMockInitialValues(saved);
      return SettingsRepositoryImpl(await SharedPreferences.getInstance());
    }

    test('returns the defaults when nothing is saved', () async {
      final repository = await createRepository({});

      expect(await repository.getConfig(), const SimulationConfig());
    });

    test('saves and loads a config', () async {
      final repository = await createRepository({});

      await repository.saveConfig(custom);

      expect(await repository.getConfig(), custom);
    });

    test('broken data falls back to the defaults', () async {
      final repository = await createRepository({
        SettingsRepositoryImpl.configKey: 'not json',
      });

      expect(await repository.getConfig(), const SimulationConfig());
    });
  });
}
