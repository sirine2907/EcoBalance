import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../stats/presentation/pages/stats_page.dart';
import '../../domain/entities/simulation_config.dart';
import '../bloc/simulation_bloc.dart';
import '../widgets/control_bar.dart';
import '../widgets/live_stats_panel.dart';
import '../widgets/world_canvas.dart';

class SimulationPage extends StatelessWidget {
  const SimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SimulationConfig>(
      // new settings -> start a fresh world with them
      listener: (context, config) {
        context.read<SimulationBloc>().add(SimulationConfigChanged(config));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EcoBalance'),
          actions: [
            IconButton(
              tooltip: 'Statistics',
              icon: const Icon(Icons.show_chart),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsPage()),
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.tune),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return const _WideLayout();
            }
            return const _NarrowLayout();
          },
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorldCanvas(),
                  SizedBox(height: 16),
                  ControlBar(),
                  SizedBox(height: 12),
                  _TapHint(),
                ],
              ),
            ),
          ),
          SizedBox(width: 24),
          SizedBox(
            width: 320,
            child: SingleChildScrollView(child: LiveStatsPanel()),
          ),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        WorldCanvas(),
        SizedBox(height: 12),
        _TapHint(),
        SizedBox(height: 16),
        ControlBar(),
        SizedBox(height: 16),
        LiveStatsPanel(),
      ],
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.touch_app_outlined, size: 18, color: AppColors.textMuted),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Tap the world to plant grass and help the rabbits.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
