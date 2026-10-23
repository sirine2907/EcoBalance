import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/level_progress.dart';
import '../../domain/usecases/get_progress.dart';

/// Best stars and scores for the level select screen.
class LevelsCubit extends Cubit<Map<int, LevelProgress>> {
  final GetProgress getProgress;

  LevelsCubit({required this.getProgress}) : super(const {});

  Future<void> load() async {
    emit(await getProgress());
  }

  /// Level 1 is always open, the others open when the one before is cleared.
  bool isUnlocked(int levelNumber) {
    if (levelNumber == 1) return true;
    return state[levelNumber - 1]?.isCleared ?? false;
  }

  int get totalStars =>
      state.values.fold(0, (sum, progress) => sum + progress.stars);
}
