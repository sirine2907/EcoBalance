import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/game/data/repositories/progress_repository_impl.dart';
import 'features/game/domain/repositories/progress_repository.dart';
import 'features/game/domain/usecases/get_progress.dart';
import 'features/game/domain/usecases/save_level_result.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_config.dart';
import 'features/settings/domain/usecases/save_config.dart';
import 'features/stats/data/repositories/stats_repository_impl.dart';
import 'features/stats/domain/repositories/stats_repository.dart';
import 'features/stats/domain/usecases/export_stats_csv.dart';

final sl = GetIt.instance;

// [prefs] can be passed in tests, otherwise we use the real ones.
Future<void> init({SharedPreferences? prefs}) async {
  await sl.reset();

  final sharedPreferences = prefs ?? await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Settings
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetConfig(sl()));
  sl.registerLazySingleton(() => SaveConfig(sl()));

  // Stats
  sl.registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl());
  sl.registerLazySingleton(() => ExportStatsCsv(sl()));

  // Game
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProgress(sl()));
  sl.registerLazySingleton(() => SaveLevelResult(sl()));
}
