import '../entities/level_progress.dart';
import '../repositories/progress_repository.dart';

class GetProgress {
  final ProgressRepository repository;

  GetProgress(this.repository);

  Future<Map<int, LevelProgress>> call() => repository.getProgress();
}
