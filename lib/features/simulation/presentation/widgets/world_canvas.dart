import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/simulation_config.dart';
import '../bloc/simulation_bloc.dart';
import 'world_painter.dart';

/// The world view. Tapping it plants grass.
class WorldCanvas extends StatelessWidget {
  /// Called with the world position of a tap. When it is null the
  /// grass is planted right away (sandbox mode).
  final void Function(double x, double y)? onTap;

  const WorldCanvas({super.key, this.onTap});

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
                final x = details.localPosition.dx * scale;
                final y = details.localPosition.dy * scale;

                if (onTap != null) {
                  onTap!(x, y);
                } else {
                  context
                      .read<SimulationBloc>()
                      .add(SimulationGrassPlanted(x, y));
                }
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
