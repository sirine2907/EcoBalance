import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../simulation/domain/entities/stats_point.dart';
import '../../domain/repositories/stats_repository.dart';
import '../csv/stats_csv.dart';

class StatsRepositoryImpl implements StatsRepository {
  /// Where the file goes. Tests pass a temp folder here.
  final Future<Directory> Function() getFolder;

  StatsRepositoryImpl({Future<Directory> Function()? getFolder})
      : getFolder = getFolder ?? getApplicationDocumentsDirectory;

  @override
  Future<String> exportCsv(List<StatsPoint> points) async {
    final folder = await getFolder();
    final time = DateTime.now().millisecondsSinceEpoch;
    final file = File('${folder.path}${Platform.pathSeparator}'
        'ecobalance_stats_$time.csv');

    await file.writeAsString(statsToCsv(points));
    return file.path;
  }
}
