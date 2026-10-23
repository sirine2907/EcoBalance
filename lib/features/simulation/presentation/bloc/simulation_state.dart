part of 'simulation_bloc.dart';

class SimulationState extends Equatable {
  final List<Animal> animals;
  final Grass grass;
  final List<StatsPoint> history;
  final int second;
  final bool isRunning;

  /// How many engine steps we do per timer tick (1, 2 or 4).
  final int speed;
  final bool showSense;

  /// Goes up on every change. The animals are mutable objects,
  /// so this is how the UI knows it has to repaint.
  final int frame;

  const SimulationState({
    required this.animals,
    required this.grass,
    required this.history,
    required this.second,
    required this.isRunning,
    required this.speed,
    required this.showSense,
    required this.frame,
  });

  int get rabbitCount => animals.where((a) => a.isRabbit).length;

  int get foxCount => animals.where((a) => a.isFox).length;

  bool get isEmpty => animals.isEmpty;

  StatsPoint? get latestStats => history.isEmpty ? null : history.last;

  @override
  List<Object?> get props => [second, isRunning, speed, showSense, frame];
}
