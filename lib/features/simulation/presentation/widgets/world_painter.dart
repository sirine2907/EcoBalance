import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/grass.dart';
import '../../domain/entities/simulation_config.dart';

/// Draws the grass grid and every animal.
/// The world is 800x500, we scale it to fit the canvas.
class WorldPainter extends CustomPainter {
  final List<Animal> animals;
  final Grass grass;
  final bool showSense;
  final int frame;

  WorldPainter({
    required this.animals,
    required this.grass,
    required this.showSense,
    required this.frame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / SimulationConfig.worldWidth;
    canvas.save();
    canvas.scale(scale);

    _paintGrass(canvas);
    if (showSense) _paintSense(canvas);
    for (final animal in animals) {
      if (animal.isRabbit) {
        _paintRabbit(canvas, animal);
      } else {
        _paintFox(canvas, animal);
      }
    }

    canvas.restore();
  }

  void _paintGrass(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(
        0,
        0,
        SimulationConfig.worldWidth,
        SimulationConfig.worldHeight,
      ),
      Paint()..color = AppColors.soil,
    );

    final grassPaint = Paint()..color = AppColors.grass;
    final cell = grass.cellSize;
    for (var row = 0; row < grass.rows; row++) {
      for (var column = 0; column < grass.columns; column++) {
        if (!grass.isGrown(column, row)) continue;
        final rect = Rect.fromLTWH(
          column * cell + 1,
          row * cell + 1,
          cell - 2,
          cell - 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          grassPaint,
        );
      }
    }
  }

  void _paintSense(Canvas canvas) {
    for (final animal in animals) {
      final color = animal.isRabbit ? AppColors.rabbit : AppColors.fox;
      canvas.drawCircle(
        Offset(animal.x, animal.y),
        animal.dna.senseRadius,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _paintRabbit(Canvas canvas, Animal rabbit) {
    final center = Offset(rabbit.x, rabbit.y);
    final r = rabbit.radius;

    // two long ears pointing backwards
    final earPaint = Paint()..color = AppColors.rabbit;
    for (final side in [-0.5, 0.5]) {
      final angle = rabbit.heading + pi + side;
      final ear = center + Offset(cos(angle), sin(angle)) * r * 1.1;
      canvas.drawCircle(ear, r * 0.45, earPaint);
    }

    canvas.drawCircle(center, r, Paint()..color = AppColors.rabbitBody);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = AppColors.rabbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintFox(Canvas canvas, Animal fox) {
    final r = fox.radius;
    final heading = fox.heading;

    // a pointy shape facing the way the fox walks
    Offset point(double angle, double distance) {
      return Offset(
        fox.x + cos(heading + angle) * distance,
        fox.y + sin(heading + angle) * distance,
      );
    }

    final body = Path()
      ..moveTo(point(0, r * 1.5).dx, point(0, r * 1.5).dy)
      ..lineTo(point(2.3, r).dx, point(2.3, r).dy)
      ..lineTo(point(pi, r * 0.6).dx, point(pi, r * 0.6).dy)
      ..lineTo(point(-2.3, r).dx, point(-2.3, r).dy)
      ..close();

    canvas.drawPath(body, Paint()..color = AppColors.foxBody);
    canvas.drawPath(
      body,
      Paint()
        ..color = AppColors.fox
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(WorldPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.showSense != showSense;
  }
}
