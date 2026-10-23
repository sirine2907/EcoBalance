import '../../../simulation/domain/entities/stats_point.dart';

const csvHeader = 'second,rabbits,foxes,grass_percent,'
    'rabbit_speed,rabbit_sense,rabbit_size,'
    'fox_speed,fox_sense,fox_size';

/// One line per point, numbers rounded so the file stays readable.
String statsToCsv(List<StatsPoint> points) {
  final buffer = StringBuffer()..writeln(csvHeader);

  for (final p in points) {
    final values = [
      p.second,
      p.rabbits,
      p.foxes,
      p.grass.toStringAsFixed(1),
      p.avgRabbitSpeed.toStringAsFixed(2),
      p.avgRabbitSense.toStringAsFixed(1),
      p.avgRabbitSize.toStringAsFixed(2),
      p.avgFoxSpeed.toStringAsFixed(2),
      p.avgFoxSense.toStringAsFixed(1),
      p.avgFoxSize.toStringAsFixed(2),
    ];
    buffer.writeln(values.join(','));
  }

  return buffer.toString();
}
