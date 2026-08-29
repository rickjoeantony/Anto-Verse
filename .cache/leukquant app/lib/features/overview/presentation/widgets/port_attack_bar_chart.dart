// lib/features/overview/presentation/widgets/port_attack_bar_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../../models/port_attack.dart';

/// A bar chart visualizing targeted decoy ports in frosted glass.
class PortAttackBarChart extends StatelessWidget {
  final List<PortAttack> data;

  const PortAttackBarChart({super.key, required this.data});

  // Fallback data when data is empty
  static const _fallbackData = <Map<String, dynamic>>[
    {'port': '22', 'count': 124},
    {'port': '443', 'count': 98},
    {'port': '8080', 'count': 67},
    {'port': '3306', 'count': 45},
    {'port': '21', 'count': 30},
  ];

  List<Map<String, dynamic>> get _chartData =>
      data.isNotEmpty ? data.map((e) => {'port': e.port, 'count': e.count}).toList() : _fallbackData;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxY = _chartData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b).toDouble();

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Targeted Decoy Ports',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
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
                        if (idx < 0 || idx >= _chartData.length) return const SizedBox.shrink();
                        final port = _chartData[idx]['port'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(port, style: TextStyle(color: colors.textSecondary, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  _chartData.length,
                  (i) {
                    final count = (_chartData[i]['count'] as int).toDouble();
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: count,
                        width: 16,
                        borderRadius: BorderRadius.circular(5),
                        color: colors.brandPrimary,
                      ),
                    ]);
                  },
                ),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
