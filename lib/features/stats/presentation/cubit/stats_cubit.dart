import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../simulation/domain/entities/stats_point.dart';
import '../../domain/usecases/export_stats_csv.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final ExportStatsCsv exportStatsCsv;

  StatsCubit({required this.exportStatsCsv}) : super(const StatsState());

  Future<void> export(List<StatsPoint> points) async {
    emit(const StatsState(status: ExportStatus.exporting));
    try {
      final path = await exportStatsCsv(points);
      emit(StatsState(status: ExportStatus.done, filePath: path));
    } catch (_) {
      emit(const StatsState(status: ExportStatus.failed));
    }
  }
}
