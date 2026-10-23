import 'package:ecobalance/features/game/data/repositories/progress_repository_impl.dart';
import 'package:ecobalance/features/game/domain/entities/level_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = ProgressRepositoryImpl(await SharedPreferences.getInstance());
  });

  test('no progress at the start', () async {
    expect(await repository.getProgress(), isEmpty);
  });

  test('saves a result', () async {
    await repository.saveResult(
      1,
      const LevelProgress(stars: 2, bestScore: 1500),
    );

    expect(await repository.getProgress(), {
      1: const LevelProgress(stars: 2, bestScore: 1500),
    });
  });

  test('keeps the best stars and the best score', () async {
    await repository.saveResult(
      1,
      const LevelProgress(stars: 3, bestScore: 1200),
    );
    await repository.saveResult(
      1,
      const LevelProgress(stars: 1, bestScore: 1800),
    );

    final progress = await repository.getProgress();
    expect(progress[1], const LevelProgress(stars: 3, bestScore: 1800));
  });

  test('broken data gives no progress', () async {
    SharedPreferences.setMockInitialValues({
      ProgressRepositoryImpl.progressKey: '{oops',
    });
    final broken =
        ProgressRepositoryImpl(await SharedPreferences.getInstance());

    expect(await broken.getProgress(), isEmpty);
  });
}
