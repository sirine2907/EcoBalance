import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/level_progress.dart';
import 'star_row.dart';

class LevelCard extends StatelessWidget {
  final Level level;
  final LevelProgress? progress;
  final bool isLocked;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.progress,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.55 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isLocked
                      ? AppColors.border
                      : AppColors.primary.withValues(alpha: 0.12),
                  child: isLocked
                      ? const Icon(Icons.lock_outline,
                          color: AppColors.textMuted)
                      : Text(
                          '${level.number}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.description,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${level.durationSeconds} s  ·  ${level.seeds} seeds',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StarRow(stars: progress?.stars ?? 0),
                    if (progress != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Best ${progress!.bestScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
