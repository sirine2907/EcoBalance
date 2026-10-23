import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../simulation/presentation/bloc/simulation_bloc.dart';
import '../../domain/game_rules.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';

/// Time left, seeds left and the three star goals.
class GameHud extends StatelessWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, game) {
        final level = game.level;
        final progress = 1 - game.secondsLeft / level.durationSeconds;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _Label(
                        title: 'Time left',
                        value: _formatTime(game.secondsLeft),
                      ),
                    ),
                    _Label(
                      title: 'Seeds',
                      value: '${game.seedsLeft} / ${level.seeds}',
                      alignEnd: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Text(
                  'Stars',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                BlocBuilder<SimulationBloc, SimulationState>(
                  builder: (context, world) {
                    final healthy = GameRules.isHealthy(
                      world.rabbitCount,
                      world.foxCount,
                    );

                    return Column(
                      children: [
                        _StarGoal(
                          text: 'Keep both species alive for '
                              '${level.durationSeconds} s',
                          done: game.status == GameStatus.won,
                        ),
                        _StarGoal(
                          text: 'Use ${level.seedGoal} seeds or less',
                          done: game.seedsUsed <= level.seedGoal,
                        ),
                        _StarGoal(
                          text: 'End with ${GameRules.healthyRabbits}+ '
                              'rabbits and ${GameRules.healthyFoxes}+ foxes',
                          done: healthy,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class _Label extends StatelessWidget {
  final String title;
  final String value;
  final bool alignEnd;

  const _Label({
    required this.title,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StarGoal extends StatelessWidget {
  final String text;
  final bool done;

  const _StarGoal({required this.text, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 20,
            color: done ? AppColors.star : AppColors.starEmpty,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
