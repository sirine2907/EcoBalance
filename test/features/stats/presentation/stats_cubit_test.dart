import 'package:bloc_test/bloc_test.dart';
import 'package:ecobalance/features/stats/domain/usecases/export_stats_csv.dart';
import 'package:ecobalance/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:ecobalance/features/stats/presentation/cubit/stats_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/sample_stats.dart';

class MockExportStatsCsv extends Mock implements ExportStatsCsv {}

void main() {
  late MockExportStatsCsv exportStatsCsv;

  setUp(() => exportStatsCsv = MockExportStatsCsv());

  blocTest<StatsCubit, StatsState>(
    'emits exporting then done with the file path',
    setUp: () => when(() => exportStatsCsv(samplePoints))
        .thenAnswer((_) async => 'C:/stats.csv'),
    build: () => StatsCubit(exportStatsCsv: exportStatsCsv),
    act: (cubit) => cubit.export(samplePoints),
    expect: () => const [
      StatsState(status: ExportStatus.exporting),
      StatsState(status: ExportStatus.done, filePath: 'C:/stats.csv'),
    ],
  );

  blocTest<StatsCubit, StatsState>(
    'emits failed when the file can not be written',
    setUp: () => when(() => exportStatsCsv(samplePoints))
        .thenThrow(Exception('disk full')),
    build: () => StatsCubit(exportStatsCsv: exportStatsCsv),
    act: (cubit) => cubit.export(samplePoints),
    expect: () => const [
      StatsState(status: ExportStatus.exporting),
      StatsState(status: ExportStatus.failed),
    ],
  );
}
