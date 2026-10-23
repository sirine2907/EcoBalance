import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/simulation_config.dart';
import '../bloc/simulation_bloc.dart';
import 'world_painter.dart';

/// The world view. Tapping it plants grass.
class WorldCanvas extends StatelessWidget {
  const WorldCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: SimulationConfig.worldWidth / SimulationConfig.worldHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) {
                // screen position -> world position
                final scale =
                    SimulationConfig.worldWidth / constraints.maxWidth;
                context.read<SimulationBloc>().add(SimulationGrassPlanted(
                      details.localPosition.dx * scale,
                      details.localPosition.dy * scale,
                    ));
              },
              child: BlocBuilder<SimulationBloc, SimulationState>(
                builder: (context, state) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: WorldPainter(
                      animals: state.animals,
                      grass: state.grass,
                      showSense: state.showSense,
                      frame: state.frame,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
