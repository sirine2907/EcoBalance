import 'package:bloc_test/bloc_test.dart';
import 'package:ecobalance/features/settings/domain/usecases/save_config.dart';
import 'package:ecobalance/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveConfig extends Mock implements SaveConfig {}

void main() {
  late MockSaveConfig saveConfig;
  const custom = SimulationConfig(startRabbits: 90);

  setUpAll(() => registerFallbackValue(const SimulationConfig()));

  setUp(() {
    saveConfig = MockSaveConfig();
    when(() => saveConfig(any())).thenAnswer((_) async {});
  });

  test('starts with the initial config', () {
    final cubit = SettingsCubit(saveConfig: saveConfig, initialConfig: custom);

    expect(cubit.state, custom);
  });

  blocTest<SettingsCubit, SimulationConfig>(
    'update emits the new config and saves it',
    build: () => SettingsCubit(saveConfig: saveConfig),
    act: (cubit) => cubit.update(custom),
    expect: () => [custom],
    verify: (_) => verify(() => saveConfig(custom)).called(1),
  );

  blocTest<SettingsCubit, SimulationConfig>(
    'resetToDefaults goes back to the default config',
    build: () => SettingsCubit(saveConfig: saveConfig, initialConfig: custom),
    act: (cubit) => cubit.resetToDefaults(),
    expect: () => [const SimulationConfig()],
  );
}
