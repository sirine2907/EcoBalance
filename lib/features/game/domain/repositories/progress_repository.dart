import '../entities/level_progress.dart';

abstract class ProgressRepository {
  /// Best result per level number. Levels never played are missing.
  Future<Map<int, LevelProgress>> getProgress();

  /// Keeps the best stars and the best score.
  Future<void> saveResult(int levelNumber, LevelProgress result);
}
