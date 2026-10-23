import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/level_progress.dart';
import '../../domain/repositories/progress_repository.dart';

/// Saves progress as json: {"1": {"stars": 2, "bestScore": 1500}, ...}
class ProgressRepositoryImpl implements ProgressRepository {
  static const progressKey = 'level_progress';

  final SharedPreferences prefs;

  ProgressRepositoryImpl(this.prefs);

  @override
  Future<Map<int, LevelProgress>> getProgress() async {
    final saved = prefs.getString(progressKey);
    if (saved == null) return {};

    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      return json.map((key, value) {
        final level = value as Map<String, dynamic>;
        return MapEntry(
          int.parse(key),
          LevelProgress(
            stars: level['stars'] as int,
            bestScore: level['bestScore'] as int,
          ),
        );
      });
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> saveResult(int levelNumber, LevelProgress result) async {
    final progress = await getProgress();
    final old = progress[levelNumber];

    progress[levelNumber] = old == null
        ? result
        : LevelProgress(
            stars: max(old.stars, result.stars),
            bestScore: max(old.bestScore, result.bestScore),
          );

    final json = progress.map((key, value) => MapEntry(
          key.toString(),
          {'stars': value.stars, 'bestScore': value.bestScore},
        ));
    await prefs.setString(progressKey, jsonEncode(json));
  }
}
