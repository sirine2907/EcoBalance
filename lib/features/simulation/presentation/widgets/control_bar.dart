import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/simulation_bloc.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationBloc, SimulationState>(
      buildWhen: (previous, current) =>
          previous.isRunning != current.isRunning ||
          previous.speed != current.speed ||
          previous.showSense != current.showSense ||
          previous.isEmpty != current.isEmpty,
      builder: (context, state) {
        final bloc = context.read<SimulationBloc>();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: state.isEmpty
                  ? null
                  : () => bloc.add(state.isRunning
                      ? const SimulationPausePressed()
                      : const SimulationPlayPressed()),
              icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(state.isRunning ? 'Pause' : 'Play'),
            ),
            OutlinedButton.icon(
              onPressed: () => bloc.add(const SimulationResetPressed()),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1x')),
                ButtonSegment(value: 2, label: Text('2x')),
                ButtonSegment(value: 4, label: Text('4x')),
              ],
              selected: {state.speed},
              showSelectedIcon: false,
              onSelectionChanged: (values) =>
                  bloc.add(SimulationSpeedChanged(values.first)),
            ),
            FilterChip(
              label: const Text('Sense radius'),
              selected: state.showSense,
              onSelected: (_) => bloc.add(const SimulationSenseToggled()),
            ),
          ],
        );
      },
    );
  }
}
