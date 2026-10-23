import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/game/presentation/cubit/levels_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/simulation/domain/engine/simulation_engine.dart';
import 'features/simulation/domain/entities/simulation_config.dart';
import 'features/simulation/presentation/bloc/simulation_bloc.dart';
import 'features/stats/presentation/cubit/stats_cubit.dart';
import 'injection_container.dart';

class EcoBalanceApp extends StatelessWidget {
  final SimulationConfig config;

  /// Tests pass a seeded random so the world is always the same.
  final Random? random;

  const EcoBalanceApp({super.key, required this.config, this.random});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsCubit(saveConfig: sl(), initialConfig: config),
        ),
        BlocProvider(
          create: (_) => SimulationBloc(
            engine: SimulationEngine(config: config, random: random),
          ),
        ),
        BlocProvider(create: (_) => StatsCubit(exportStatsCsv: sl())),
        BlocProvider(create: (_) => LevelsCubit(getProgress: sl())),
      ],
      child: MaterialApp(
        title: 'EcoBalance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
      ),
    );
  }
}
