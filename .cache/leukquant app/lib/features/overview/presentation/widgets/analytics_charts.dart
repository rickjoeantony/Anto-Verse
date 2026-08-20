// lib/features/overview/presentation/widgets/analytics_charts.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/chart_empty_state.dart';

/// 1. Simple Security Activity Line Chart for business customers
class SecurityActivityLineChart extends StatelessWidget {
  final List<double>? dataPoints;

  const SecurityActivityLineChart({super.key, this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Observed security signals over time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dataPoints == null || dataPoints!.isEmpty)
            const ChartEmptyState(
              title: 'No Verified Activity',
              description: 'Activity trend will appear after telemetry is connected.',
              icon: Icons.show_chart_rounded,
              height: 150,
            )
          else
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: 4,
                        getTitlesWidget: (val, meta) => Text(
                          val.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (dataPoints!.length - 1).toDouble(),
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        dataPoints!.length,
                        (i) => FlSpot(i.toDouble(), dataPoints![i]),
                      ),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: colors.brandPrimary,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.brandPrimary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 2. Threat Distribution Donut Chart with balanced legend alignment
class ThreatDistributionDonutChart extends StatelessWidget {
  final Map<String, double>? threatData;

  const ThreatDistributionDonutChart({super.key, this.threatData});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorMap = {
      'Reconnaissance': colors.brandPrimary,
      'Credential Attack': colors.high,
      'Canary Interaction': colors.brandSecondary,
      'Critical Incident': colors.critical,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Threat Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Telemetry categorisation breakdown',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (threatData == null || threatData!.isEmpty)
            const ChartEmptyState(
              title: 'No Classified Threats',
              description: 'Threat distribution analytics awaiting telemetry data.',
              icon: Icons.pie_chart_outline_rounded,
              height: 140,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 340;
                final donutWidget = SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 30,
                      sections: threatData!.entries.map((entry) {
                        final sectionColor = colorMap[entry.key] ?? colors.brandPrimary;
                        return PieChartSectionData(
                          color: sectionColor,
                          value: entry.value,
                          title: '${entry.value.toInt()}%',
                          radius: 22,
                          titleStyle: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );

                final legendWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: threatData!.entries.map((entry) {
                    final sectionColor = colorMap[entry.key] ?? colors.brandPrimary;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.5),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: sectionColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.value.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (isWide) {
                  return Row(
                    children: [
                      donutWidget,
                      const SizedBox(width: 20),
                      Expanded(child: legendWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Center(child: donutWidget),
                      const SizedBox(height: 14),
                      legendWidget,
                    ],
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

/// 3. Protocol Activity Bar Chart with balanced alignment
class ProtocolActivityBarChart extends StatelessWidget {
  final Map<String, double>? protocolData;

  const ProtocolActivityBarChart({super.key, this.protocolData});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Targeted Decoy Ports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Observed port interactions (target_port only)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (protocolData == null || protocolData!.isEmpty)
            const ChartEmptyState(
              title: 'No Port Traffic',
              description: 'Targeted port analytics awaiting telemetry data.',
              icon: Icons.bar_chart_rounded,
              height: 140,
            )
          else
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 50,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = protocolData!.keys.toList();
                          final idx = value.toInt();
                          if (idx >= 0 && idx < keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                keys[idx],
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: protocolData!.entries.toList().asMap().entries.map((item) {
                    final index = item.key;
                    final val = item.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          color: colors.brandPrimary,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 50,
                            color: colors.surfaceMuted,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
