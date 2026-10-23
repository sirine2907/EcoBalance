part of 'simulation_bloc.dart';

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();

  @override
  List<Object?> get props => [];
}

class SimulationPlayPressed extends SimulationEvent {
  const SimulationPlayPressed();
}

class SimulationPausePressed extends SimulationEvent {
  const SimulationPausePressed();
}

/// Sent by the timer, moves the world forward.
class SimulationTicked extends SimulationEvent {
  const SimulationTicked();
}

class SimulationResetPressed extends SimulationEvent {
  const SimulationResetPressed();
}

class SimulationSpeedChanged extends SimulationEvent {
  final int speed;

  const SimulationSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class SimulationSenseToggled extends SimulationEvent {
  const SimulationSenseToggled();
}

/// The user tapped the canvas. [x] and [y] are in world coordinates.
class SimulationGrassPlanted extends SimulationEvent {
  final double x;
  final double y;

  const SimulationGrassPlanted(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}

/// New settings were saved, start over with them.
class SimulationConfigChanged extends SimulationEvent {
  final SimulationConfig config;

  const SimulationConfigChanged(this.config);

  @override
  List<Object?> get props => [config];
}
