import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/simulation_bloc.dart';

/// Population counters and the average genes of each species.
class LiveStatsPanel extends StatelessWidget {
  const LiveStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationBloc, SimulationState>(
      builder: (context, state) {
        final stats = state.latestStats;
        final grassPercent = (state.grass.coverage * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    label: 'Rabbits',
                    value: '${state.rabbitCount}',
                    color: AppColors.rabbit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'Foxes',
                    value: '${state.foxCount}',
                    color: AppColors.fox,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    label: 'Grass',
                    value: '$grassPercent%',
                    color: AppColors.grass,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'Time',
                    value: _formatTime(state.second),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (state.rabbitCount == 0 || state.foxCount == 0) ...[
              const SizedBox(height: 12),
              _ExtinctBanner(rabbitsGone: state.rabbitCount == 0),
            ],
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average genes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const _GeneRow(
                      label: '',
                      rabbit: 'Rabbit',
                      fox: 'Fox',
                      isHeader: true,
                    ),
                    _GeneRow(
                      label: 'Speed',
                      rabbit: _format(stats?.avgRabbitSpeed, 2),
                      fox: _format(stats?.avgFoxSpeed, 2),
                    ),
                    _GeneRow(
                      label: 'Sense',
                      rabbit: _format(stats?.avgRabbitSense, 0),
                      fox: _format(stats?.avgFoxSense, 0),
                    ),
                    _GeneRow(
                      label: 'Size',
                      rabbit: _format(stats?.avgRabbitSize, 2),
                      fox: _format(stats?.avgFoxSize, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _format(double? value, int digits) {
    if (value == null || value == 0) return '-';
    return value.toStringAsFixed(digits);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneRow extends StatelessWidget {
  final String label;
  final String rabbit;
  final String fox;
  final bool isHeader;

  const _GeneRow({
    required this.label,
    required this.rabbit,
    required this.fox,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isHeader ? AppColors.textMuted : null,
      fontWeight: isHeader ? FontWeight.w500 : FontWeight.w600,
      fontSize: isHeader ? 12 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(rabbit, style: style, textAlign: TextAlign.end),
          ),
          SizedBox(
            width: 64,
            child: Text(fox, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _ExtinctBanner extends StatelessWidget {
  final bool rabbitsGone;

  const _ExtinctBanner({required this.rabbitsGone});

  @override
  Widget build(BuildContext context) {
    final text = rabbitsGone
        ? 'The rabbits are gone. Press Reset to try again.'
        : 'The foxes died out. Rabbits rule the world now.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF6C9A4)),
      ),
      child: Text(text),
    );
  }
}
