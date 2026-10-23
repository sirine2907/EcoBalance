import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:ecobalance/features/simulation/domain/engine/simulation_engine.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:ecobalance/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

SimulationBloc createBloc({SimulationConfig config = const SimulationConfig()}) {
  return SimulationBloc(
    engine: SimulationEngine(config: config, random: Random(1)),
    // long enough that the timer never fires during a test
    tickRate: const Duration(hours: 1),
  );
}

void main() {
  test('starts paused at 1x with the starting animals', () {
    final bloc = createBloc();

    expect(bloc.state.isRunning, isFalse);
    expect(bloc.state.speed, 1);
    expect(bloc.state.showSense, isFalse);
    expect(bloc.state.rabbitCount, 40);
    expect(bloc.state.foxCount, 6);

    bloc.close();
  });

  blocTest<SimulationBloc, SimulationState>(
    'play and pause',
    build: createBloc,
    act: (bloc) => bloc
      ..add(const SimulationPlayPressed())
      ..add(const SimulationPausePressed()),
    expect: () => [
      isA<SimulationState>().having((s) => s.isRunning, 'isRunning', true),
      isA<SimulationState>().having((s) => s.isRunning, 'isRunning', false),
    ],
  );

  blocTest<SimulationBloc, SimulationState>(
    'one second of ticks moves the clock',
    build: createBloc,
    act: (bloc) {
      for (var i = 0; i < SimulationEngine.ticksPerSecond; i++) {
        bloc.add(const SimulationTicked());
      }
    },
    skip: SimulationEngine.ticksPerSecond - 1,
    expect: () => [
      isA<SimulationState>()
          .having((s) => s.second, 'second', 1)
          .having((s) => s.history.length, 'history', 2),
    ],
  );

  blocTest<SimulationBloc, SimulationState>(
    'speed 4 runs four steps per tick',
    build: createBloc,
    act: (bloc) {
      bloc.add(const SimulationSpeedChanged(4));
      for (var i = 0; i < SimulationEngine.ticksPerSecond ~/ 2; i++) {
        bloc.add(const SimulationTicked());
      }
    },
    verify: (bloc) {
      expect(bloc.state.speed, 4);
      expect(bloc.state.second, 2);
    },
  );

  blocTest<SimulationBloc, SimulationState>(
    'toggles the sense radius',
    build: createBloc,
    act: (bloc) => bloc.add(const SimulationSenseToggled()),
    expect: () => [
      isA<SimulationState>().having((s) => s.showSense, 'showSense', true),
    ],
  );

  blocTest<SimulationBloc, SimulationState>(
    'planting grass grows the tapped cell',
    build: createBloc,
    act: (bloc) => bloc.add(const SimulationGrassPlanted(400, 250)),
    verify: (bloc) {
      final grass = bloc.state.grass;
      expect(grass.isGrown(grass.columnOf(400), grass.rowOf(250)), isTrue);
    },
  );

  blocTest<SimulationBloc, SimulationState>(
    'reset goes back to second 0 and pauses',
    build: createBloc,
    act: (bloc) {
      bloc.add(const SimulationPlayPressed());
      for (var i = 0; i < 60; i++) {
        bloc.add(const SimulationTicked());
      }
      bloc.add(const SimulationResetPressed());
    },
    verify: (bloc) {
      expect(bloc.state.second, 0);
      expect(bloc.state.isRunning, isFalse);
      expect(bloc.state.history.length, 1);
    },
  );

  blocTest<SimulationBloc, SimulationState>(
    'new config starts a new world with it',
    build: createBloc,
    act: (bloc) => bloc.add(const SimulationConfigChanged(
      SimulationConfig(startRabbits: 10, startFoxes: 2),
    )),
    verify: (bloc) {
      expect(bloc.state.rabbitCount, 10);
      expect(bloc.state.foxCount, 2);
    },
  );

  blocTest<SimulationBloc, SimulationState>(
    'play does nothing when the world is empty',
    build: () => createBloc(
      config: const SimulationConfig(startRabbits: 0, startFoxes: 0),
    ),
    act: (bloc) => bloc.add(const SimulationPlayPressed()),
    expect: () => [],
  );
}
