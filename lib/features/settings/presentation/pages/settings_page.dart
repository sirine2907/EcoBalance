import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../simulation/domain/engine/simulation_engine.dart';
import '../../../simulation/domain/entities/simulation_config.dart';
import '../cubit/settings_cubit.dart';

/// The user changes a copy of the config and saves it with the button.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SimulationConfig _config;

  @override
  void initState() {
    super.initState();
    _config = context.read<SettingsCubit>().state;
  }

  Future<void> _save() async {
    await context.read<SettingsCubit>().update(_config);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _config = const SimulationConfig()),
            child: const Text('Defaults'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Section(
                title: 'Animals',
                children: [
                  _SettingSlider(
                    label: 'Starting rabbits',
                    value: _config.startRabbits.toDouble(),
                    min: 5,
                    max: 150,
                    divisions: 29,
                    display: '${_config.startRabbits}',
                    onChanged: (v) => setState(() => _config =
                        _config.copyWith(startRabbits: v.round())),
                  ),
                  _SettingSlider(
                    label: 'Starting foxes',
                    value: _config.startFoxes.toDouble(),
                    min: 0,
                    max: SimulationEngine.maxFoxes.toDouble(),
                    divisions: SimulationEngine.maxFoxes,
                    display: '${_config.startFoxes}',
                    onChanged: (v) => setState(() =>
                        _config = _config.copyWith(startFoxes: v.round())),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'World',
                children: [
                  _SettingSlider(
                    label: 'Grass growth',
                    hint: 'Chance for a bare cell to grow back each tick',
                    value: _config.grassGrowthRate,
                    min: 0.0005,
                    max: 0.005,
                    divisions: 18,
                    display:
                        '${(_config.grassGrowthRate * 100).toStringAsFixed(2)}%',
                    onChanged: (v) => setState(
                        () => _config = _config.copyWith(grassGrowthRate: v)),
                  ),
                  _SettingSlider(
                    label: 'Mutation rate',
                    hint: 'How much a baby can differ from its parent',
                    value: _config.mutationRate,
                    min: 0,
                    max: 0.5,
                    divisions: 20,
                    display: '${(_config.mutationRate * 100).round()}%',
                    onChanged: (v) => setState(
                        () => _config = _config.copyWith(mutationRate: v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Energy cost',
                children: [
                  _SettingSlider(
                    label: 'Rabbits',
                    hint: 'Higher means rabbits get hungry faster',
                    value: _config.rabbitEnergyCost,
                    min: 0.5,
                    max: 2,
                    divisions: 15,
                    display: '${_config.rabbitEnergyCost.toStringAsFixed(1)}x',
                    onChanged: (v) => setState(
                        () => _config = _config.copyWith(rabbitEnergyCost: v)),
                  ),
                  _SettingSlider(
                    label: 'Foxes',
                    hint: 'Higher means foxes get hungry faster',
                    value: _config.foxEnergyCost,
                    min: 0.5,
                    max: 2,
                    divisions: 15,
                    display: '${_config.foxEnergyCost.toStringAsFixed(1)}x',
                    onChanged: (v) => setState(
                        () => _config = _config.copyWith(foxEnergyCost: v)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save and restart'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final String? hint;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.label,
    this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(display, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          if (hint != null)
            Text(
              hint!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
