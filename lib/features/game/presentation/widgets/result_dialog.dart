import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/game_rules.dart';
import '../cubit/game_state.dart';
import 'star_row.dart';

enum ResultAction { levels, retry, next }

/// Shown when a level ends. Returns what the player picked.
Future<ResultAction?> showResultDialog(
  BuildContext context,
  GameState game, {
  required bool hasNextLevel,
}) {
  return showDialog<ResultAction>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ResultDialog(game: game, hasNextLevel: hasNextLevel),
  );
}

class ResultDialog extends StatelessWidget {
  final GameState game;
  final bool hasNextLevel;

  const ResultDialog({
    super.key,
    required this.game,
    required this.hasNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final won = game.status == GameStatus.won;
    final survived = game.level.durationSeconds - game.secondsLeft;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events_rounded : Icons.cloud_off_rounded,
              size: 48,
              color: won ? AppColors.star : AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              won ? 'Level complete!' : 'The ecosystem collapsed',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            StarRow(stars: game.stars, size: 40),
            const SizedBox(height: 16),
            if (won) ...[
              Text(
                '${game.score} points',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'You used ${game.seedsUsed} of ${game.level.seeds} seeds.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ] else
              Text(
                game.rabbitsDied
                    ? 'The rabbits died out after $survived s. '
                        'Try planting grass earlier.'
                    : 'The foxes died out after $survived s. '
                        'More rabbits means more food for them.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ResultAction.levels),
          child: const Text('Levels'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(ResultAction.retry),
          child: const Text('Retry'),
        ),
        if (won && hasNextLevel)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ResultAction.next),
            child: const Text('Next level'),
          ),
      ],
    );
  }
}
