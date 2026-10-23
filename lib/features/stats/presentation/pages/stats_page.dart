import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../simulation/domain/entities/stats_point.dart';
import '../../../simulation/presentation/bloc/simulation_bloc.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';
import '../widgets/stats_line_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatsCubit, StatsState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == ExportStatus.done) {
          messenger.showSnackBar(
            SnackBar(content: Text('Saved to ${state.filePath}')),
          );
        } else if (state.status == ExportStatus.failed) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Could not save the csv file')),
          );
        }
      },
      child: BlocBuilder<SimulationBloc, SimulationState>(
        builder: (context, state) {
          final history = state.history;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Statistics'),
              actions: [
                TextButton.icon(
                  onPressed: history.isEmpty
                      ? null
                      : () => context.read<StatsCubit>().export(history),
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: history.length < 2
                ? const _EmptyStats()
                : _Charts(history: history),
          );
        },
      ),
    );
  }
}

class _Charts extends StatelessWidget {
  final List<StatsPoint> history;

  const _Charts({required this.history});

  List<FlSpot> _spots(double Function(StatsPoint p) value) {
    return [
      for (final p in history) FlSpot(p.second.toDouble(), value(p)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final charts = [
      StatsLineChart(
        title: 'Rabbits',
        series: [
          ChartSeries(
            label: 'Rabbits',
            color: AppColors.rabbit,
            spots: _spots((p) => p.rabbits.toDouble()),
          ),
        ],
      ),
      StatsLineChart(
        title: 'Foxes',
        series: [
          ChartSeries(
            label: 'Foxes',
            color: AppColors.fox,
            spots: _spots((p) => p.foxes.toDouble()),
          ),
        ],
      ),
      StatsLineChart(
        title: 'Grass coverage (%)',
        maxY: 100,
        series: [
          ChartSeries(
            label: 'Grass',
            color: AppColors.grass,
            spots: _spots((p) => p.grass),
          ),
        ],
      ),
      StatsLineChart(
        title: 'Average speed',
        series: [
          ChartSeries(
            label: 'Rabbit',
            color: AppColors.rabbit,
            spots: _spots((p) => p.avgRabbitSpeed),
          ),
          ChartSeries(
            label: 'Fox',
            color: AppColors.fox,
            spots: _spots((p) => p.avgFoxSpeed),
          ),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // two columns on big screens, one on phones
        final columns = constraints.maxWidth >= 900 ? 2 : 1;
        final padding = columns == 2 ? 24.0 : 16.0;
        final width =
            (constraints.maxWidth - padding * 2 - 16 * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final chart in charts) SizedBox(width: width, child: chart),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No data yet. Press Play and come back in a few seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
