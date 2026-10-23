import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../simulation/domain/engine/simulation_engine.dart';
import '../../../simulation/presentation/bloc/simulation_bloc.dart';
import '../../../simulation/presentation/widgets/control_bar.dart';
import '../../../simulation/presentation/widgets/live_stats_panel.dart';
import '../../../simulation/presentation/widgets/world_canvas.dart';
import '../../domain/entities/level.dart';
import '../../domain/levels.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/game_hud.dart';
import '../widgets/result_dialog.dart';

/// Plays one level. It has its own simulation, separate from the sandbox.
class GamePage extends StatelessWidget {
  final Level level;

  /// Tests pass a seeded random so the level is always the same.
  final Random? random;

  const GamePage({super.key, required this.level, this.random});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SimulationBloc(
            engine: SimulationEngine(config: level.config, random: random),
          ),
        ),
        BlocProvider(
          create: (_) => GameCubit(level: level, saveLevelResult: sl()),
        ),
      ],
      child: _GameView(random: random),
    );
  }
}

class _GameView extends StatelessWidget {
  final Random? random;

  const _GameView({this.random});

  void _plantGrass(BuildContext context, double x, double y) {
    final usedSeed = context.read<GameCubit>().useSeed();
    if (usedSeed) {
      context.read<SimulationBloc>().add(SimulationGrassPlanted(x, y));
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No seeds left!')));
    }
  }

  Future<void> _showResult(BuildContext context, GameState game) async {
    context.read<SimulationBloc>().add(const SimulationPausePressed());

    final index = levels.indexOf(game.level);
    final hasNext = index + 1 < levels.length;
    final action =
        await showResultDialog(context, game, hasNextLevel: hasNext);
    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    switch (action) {
      case ResultAction.retry:
        navigator.pushReplacement(MaterialPageRoute(
          builder: (_) => GamePage(level: game.level, random: random),
        ));
      case ResultAction.next:
        navigator.pushReplacement(MaterialPageRoute(
          builder: (_) => GamePage(level: levels[index + 1], random: random),
        ));
      case ResultAction.levels:
      case null:
        navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = context.read<GameCubit>().state.level;

    return MultiBlocListener(
      listeners: [
        BlocListener<SimulationBloc, SimulationState>(
          listener: (context, world) {
            context.read<GameCubit>().worldChanged(
                  second: world.second,
                  rabbits: world.rabbitCount,
                  foxes: world.foxCount,
                );
          },
        ),
        BlocListener<GameCubit, GameState>(
          listenWhen: (previous, current) =>
              !previous.isOver && current.isOver,
          listener: _showResult,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text('Level ${level.number} · ${level.name}')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final canvas = WorldCanvas(
              onTap: (x, y) => _plantGrass(context, x, y),
            );

            if (constraints.maxWidth >= 900) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            canvas,
                            const SizedBox(height: 16),
                            const ControlBar(showReset: false),
                            const SizedBox(height: 12),
                            const _GameHint(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const SizedBox(
                      width: 320,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GameHud(),
                            SizedBox(height: 12),
                            LiveStatsPanel(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                canvas,
                const SizedBox(height: 12),
                const _GameHint(),
                const SizedBox(height: 16),
                const ControlBar(showReset: false),
                const SizedBox(height: 16),
                const GameHud(),
                const SizedBox(height: 12),
                const LiveStatsPanel(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameHint extends StatelessWidget {
  const _GameHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.touch_app_outlined, size: 18, color: AppColors.textMuted),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Press Play. Tap the world to plant grass, each tap uses one seed. '
            'Don\'t let rabbits or foxes die out!',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
