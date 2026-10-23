import '../../../simulation/domain/entities/stats_point.dart';
import '../repositories/stats_repository.dart';

class ExportStatsCsv {
  final StatsRepository repository;

  ExportStatsCsv(this.repository);

  Future<String> call(List<StatsPoint> points) =>
      repository.exportCsv(points);
}
