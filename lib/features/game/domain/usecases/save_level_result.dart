import '../entities/level_progress.dart';
import '../repositories/progress_repository.dart';

class SaveLevelResult {
  final ProgressRepository repository;

  SaveLevelResult(this.repository);

  Future<void> call(int levelNumber, LevelProgress result) =>
      repository.saveResult(levelNumber, result);
}
