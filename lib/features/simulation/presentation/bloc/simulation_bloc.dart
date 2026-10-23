import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/engine/simulation_engine.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/grass.dart';
import '../../domain/entities/simulation_config.dart';
import '../../domain/entities/stats_point.dart';

part 'simulation_event.dart';
part 'simulation_state.dart';

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final SimulationEngine engine;

  /// About 30 frames per second.
  final Duration tickRate;

  Timer? _timer;
  int _frame = 0;

  SimulationBloc({
    required this.engine,
    this.tickRate = const Duration(milliseconds: 33),
  }) : super(SimulationState(
          animals: List.of(engine.animals),
          grass: engine.grass,
          history: List.of(engine.history),
          second: engine.second,
          isRunning: false,
          speed: 1,
          showSense: false,
          frame: 0,
        )) {
    on<SimulationPlayPressed>(_onPlay);
    on<SimulationPausePressed>(_onPause);
    on<SimulationTicked>(_onTicked);
    on<SimulationResetPressed>(_onReset);
    on<SimulationSpeedChanged>(_onSpeedChanged);
    on<SimulationSenseToggled>(_onSenseToggled);
    on<SimulationGrassPlanted>(_onGrassPlanted);
    on<SimulationConfigChanged>(_onConfigChanged);
  }

  void _onPlay(SimulationPlayPressed event, Emitter<SimulationState> emit) {
    if (state.isEmpty) return;

    _timer?.cancel();
    _timer = Timer.periodic(tickRate, (_) => add(const SimulationTicked()));
    emit(_buildState(isRunning: true));
  }

  void _onPause(SimulationPausePressed event, Emitter<SimulationState> emit) {
    _timer?.cancel();
    emit(_buildState(isRunning: false));
  }

  void _onTicked(SimulationTicked event, Emitter<SimulationState> emit) {
    for (var i = 0; i < state.speed; i++) {
      engine.step();
    }

    // nothing left alive, no need to keep the timer going
    if (engine.animals.isEmpty) {
      _timer?.cancel();
      emit(_buildState(isRunning: false));
      return;
    }

    emit(_buildState());
  }

  void _onReset(SimulationResetPressed event, Emitter<SimulationState> emit) {
    _timer?.cancel();
    engine.reset();
    emit(_buildState(isRunning: false));
  }

  void _onSpeedChanged(
    SimulationSpeedChanged event,
    Emitter<SimulationState> emit,
  ) {
    emit(_buildState(speed: event.speed));
  }

  void _onSenseToggled(
    SimulationSenseToggled event,
    Emitter<SimulationState> emit,
  ) {
    emit(_buildState(showSense: !state.showSense));
  }

  void _onGrassPlanted(
    SimulationGrassPlanted event,
    Emitter<SimulationState> emit,
  ) {
    engine.plantGrass(event.x, event.y);
    emit(_buildState());
  }

  void _onConfigChanged(
    SimulationConfigChanged event,
    Emitter<SimulationState> emit,
  ) {
    _timer?.cancel();
    engine.reset(event.config);
    emit(_buildState(isRunning: false));
  }

  SimulationState _buildState({bool? isRunning, int? speed, bool? showSense}) {
    _frame++;
    return SimulationState(
      animals: List.of(engine.animals),
      grass: engine.grass,
      history: List.of(engine.history),
      second: engine.second,
      isRunning: isRunning ?? state.isRunning,
      speed: speed ?? state.speed,
      showSense: showSense ?? state.showSense,
      frame: _frame,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
