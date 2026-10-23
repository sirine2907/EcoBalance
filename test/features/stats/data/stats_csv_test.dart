import 'dart:io';

import 'package:ecobalance/features/stats/data/csv/stats_csv.dart';
import 'package:ecobalance/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_stats.dart';

void main() {
  group('statsToCsv', () {
    test('writes a header and one line per point', () {
      final lines = statsToCsv(samplePoints).trim().split('\n');

      expect(lines.length, 3);
      expect(lines.first, csvHeader);
      expect(lines[2], '1,42,6,38.3,1.51,40.4,1.00,2.00,60.0,1.20');
    });

    test('only the header when there are no points', () {
      expect(statsToCsv([]).trim(), csvHeader);
    });
  });

  group('StatsRepositoryImpl', () {
    late Directory folder;

    setUp(() async {
      folder = await Directory.systemTemp.createTemp('ecobalance_test');
    });

    tearDown(() => folder.delete(recursive: true));

    test('saves the csv in the folder and returns the path', () async {
      final repository = StatsRepositoryImpl(getFolder: () async => folder);

      final path = await repository.exportCsv(samplePoints);

      final file = File(path);
      expect(file.parent.path, folder.path);
      expect(await file.readAsString(), statsToCsv(samplePoints));
    });
  });
}
