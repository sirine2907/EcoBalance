import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/level.dart';
import '../../domain/entities/level_progress.dart';
import '../../domain/game_rules.dart';
import '../../domain/usecases/save_level_result.dart';
import 'game_state.dart';

/// Watches the simulation and decides when the level is won or lost.
class GameCubit extends Cubit<GameState> {
  final SaveLevelResult saveLevelResult;

  GameCubit({required Level level, required this.saveLevelResult})
      : super(GameState(
          level: level,
          status: GameStatus.playing,
          seedsLeft: level.seeds,
          secondsLeft: level.durationSeconds,
        ));

  /// Uses one seed. Returns false when there are none left.
  bool useSeed() {
    if (state.isOver || state.seedsLeft == 0) return false;
    emit(state.copyWith(seedsLeft: state.seedsLeft - 1));
    return true;
  }

  /// Called every time the simulation changes.
  Future<void> worldChanged({
    required int second,
    required int rabbits,
    required int foxes,
  }) async {
    if (state.isOver) return;

    final level = state.level;
    final secondsLeft = max(0, level.durationSeconds - second);
    final status = GameRules.check(
      level: level,
      second: second,
      rabbits: rabbits,
      foxes: foxes,
    );

    if (status == GameStatus.playing) {
      if (secondsLeft != state.secondsLeft) {
        emit(state.copyWith(secondsLeft: secondsLeft));
      }
      return;
    }

    if (status == GameStatus.lost) {
      emit(state.copyWith(
        status: GameStatus.lost,
        secondsLeft: secondsLeft,
        rabbitsDied: rabbits == 0,
      ));
      return;
    }

    final stars = GameRules.stars(
      level: level,
      seedsUsed: state.seedsUsed,
      rabbits: rabbits,
      foxes: foxes,
    );
    final score = GameRules.score(
      seedsLeft: state.seedsLeft,
      rabbits: rabbits,
      foxes: foxes,
    );

    emit(state.copyWith(
      status: GameStatus.won,
      secondsLeft: 0,
      stars: stars,
      score: score,
    ));
    await saveLevelResult(
      level.number,
      LevelProgress(stars: stars, bestScore: score),
    );
  }
}
