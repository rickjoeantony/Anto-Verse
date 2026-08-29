// lib/features/overview/presentation/widgets/targeted_ports_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_card.dart';
import '../../../../shared/models/port_attack_summary.dart';
import '../../../../core/widgets/chart_empty_state.dart';

/// Bar chart visualizing targeted decoy ports in Liquid Glass.
/// Shows the count of attacks per target port as provided by the backend.
class TargetedPortsChart extends StatelessWidget {
  final List<PortAttackSummary> data;

  const TargetedPortsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return LiquidGlassCard(
      cornerRadius: 24.0,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Targeted Decoy Ports',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          if (data.isEmpty)
            const ChartEmptyState(
              title: 'No Targeted Port Data',
              description: 'Targeted port analytics awaiting telemetry data.',
              icon: Icons.bar_chart_rounded,
              height: 160,
            )
          else
            _buildChart(context, colors),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, AppColorScheme colors) {
    final maxY = data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY + 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  final port = data[idx].port;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      port,
                      style: TextStyle(color: colors.textSecondary, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            data.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].count.toDouble(),
                  width: 16,
                  borderRadius: BorderRadius.circular(5),
                  color: colors.brandPrimary,
                ),
              ],
            ),
          ),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }
}
