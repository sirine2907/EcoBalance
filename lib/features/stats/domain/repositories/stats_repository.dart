import '../../../simulation/domain/entities/stats_point.dart';

abstract class StatsRepository {
  /// Writes the points to a csv file and returns where it was saved.
  Future<String> exportCsv(List<StatsPoint> points);
}
