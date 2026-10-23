import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChartSeries {
  final String label;
  final Color color;
  final List<FlSpot> spots;

  const ChartSeries({
    required this.label,
    required this.color,
    required this.spots,
  });
}

/// A card with a title, a small legend and a line chart.
/// x is always the time in seconds.
class StatsLineChart extends StatelessWidget {
  final String title;
  final List<ChartSeries> series;
  final double? maxY;

  const StatsLineChart({
    super.key,
    required this.title,
    required this.series,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final s in series) ...[
                  const SizedBox(width: 12),
                  _LegendDot(color: s.color),
                  const SizedBox(width: 4),
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 24),
                    ),
                  ),
                  lineBarsData: [
                    for (final s in series)
                      LineChartBarData(
                        spots: s.spots,
                        color: s.color,
                        barWidth: 2,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: series.length == 1,
                          color: s.color.withValues(alpha: 0.12),
                        ),
                      ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
