// lib/features/overview/presentation/widgets/analytics_charts.dart

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/chart_empty_state.dart';
import '../../../../core/widgets/glass/glass_container.dart';

/// 1. Enhanced Security Activity Line Chart — premium AI-grade visualization
class SecurityActivityLineChart extends StatefulWidget {
  final List<double>? dataPoints;
  const SecurityActivityLineChart({super.key, this.dataPoints});

  @override
  State<SecurityActivityLineChart> createState() =>
      _SecurityActivityLineChartState();
}

class _SecurityActivityLineChartState extends State<SecurityActivityLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasData = widget.dataPoints != null && widget.dataPoints!.isNotEmpty;
    final pts = widget.dataPoints ?? [];
    final maxVal = hasData ? pts.reduce(math.max) : 10.0;
    final minVal = hasData ? pts.reduce(math.min) : 0.0;
    final avgVal = hasData ? pts.reduce((a, b) => a + b) / pts.length : 0.0;
    final calculatedMaxY = maxVal > 0 ? (maxVal * 1.3).ceilToDouble() : 10.0;
    final interval = (calculatedMaxY / 4).ceilToDouble().clamp(1.0, 1000.0);

    return GlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Activity',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Telemetry signal trend over time',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Live dot + label
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.success.withValues(alpha: 0.55),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Chart ─────────────────────────────────────────────────────
          if (!hasData)
            const ChartEmptyState(
              title: 'No Activity Data',
              description: 'Telemetry trend will appear once signals are received.',
              icon: Icons.show_chart_rounded,
              height: 140,
            )
          else ...[
            SizedBox(
              height: 155,
              child: LineChart(
                duration: const Duration(milliseconds: 400),
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      if (response?.lineBarSpots != null &&
                          response!.lineBarSpots!.isNotEmpty) {
                        setState(() =>
                            _touchedIndex = response.lineBarSpots![0].spotIndex);
                      } else {
                        setState(() => _touchedIndex = null);
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => isDark
                          ? const Color(0xFF1A2840)
                          : Colors.white,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItems: (spots) => spots.map((spot) {
                        return LineTooltipItem(
                          spot.y.toInt().toString(),
                          TextStyle(
                            color: colors.brandPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: '\nSignals',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: interval,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            val.toInt().toString(),
                            style: TextStyle(
                              fontSize: 9.5,
                              color: colors.textSecondary
                                  .withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (pts.length - 1).toDouble(),
                  minY: 0,
                  maxY: calculatedMaxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          pts.length, (i) => FlSpot(i.toDouble(), pts[i])),
                      isCurved: true,
                      curveSmoothness: 0.4,
                      gradient: LinearGradient(
                        colors: [
                          colors.brandPrimary.withValues(alpha: 0.6),
                          colors.brandPrimary,
                          colors.brandSecondary,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isTouched = _touchedIndex == index;
                          return FlDotCirclePainter(
                            radius: isTouched ? 5 : 2.5,
                            color: isTouched
                                ? colors.brandPrimary
                                : colors.brandPrimary.withValues(alpha: 0.0),
                            strokeWidth: isTouched ? 2 : 0,
                            strokeColor: isTouched
                                ? Colors.white
                                : Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.brandPrimary.withValues(alpha: isDark ? 0.22 : 0.14),
                            colors.brandPrimary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Mini stats row ────────────────────────────────────────
            Row(
              children: [
                _StatChip(label: 'Peak', value: maxVal.toInt().toString(), color: colors.critical),
                const SizedBox(width: 8),
                _StatChip(label: 'Avg', value: avgVal.toStringAsFixed(1), color: colors.brandPrimary),
                const SizedBox(width: 8),
                _StatChip(label: 'Min', value: minVal.toInt().toString(), color: colors.success),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Small stat chip for the chart stats row
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5.5,
          height: 5.5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: colors.textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// 2. Premium Threat Distribution Chart — interactive donut with animated center + progress bar legend
class ThreatDistributionDonutChart extends StatefulWidget {
  final Map<String, double>? threatData;
  const ThreatDistributionDonutChart({super.key, this.threatData});

  @override
  State<ThreatDistributionDonutChart> createState() =>
      _ThreatDistributionDonutChartState();
}

class _ThreatDistributionDonutChartState
    extends State<ThreatDistributionDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Disciplined cohesive cybersecurity palette (no rainbow clutter)
    final palette = [
      colors.brandPrimary,
      const Color(0xFF64D2FF), // Ice Cyan
      const Color(0xFF5E5CE6), // Deep Indigo
      colors.brandSecondary,   // Teal
      colors.warning,          // Amber
      colors.critical,         // Coral
      colors.textSecondary,    // Slate
    ];

    final hasData = widget.threatData != null && widget.threatData!.isNotEmpty;
    final entries = widget.threatData?.entries.toList() ?? [];
    final total = hasData
        ? entries.fold(0.0, (sum, e) => sum + e.value)
        : 0.0;

    // Which section is selected (or show total in center)
    final isSectionSelected = _touchedIndex >= 0 && _touchedIndex < entries.length;
    final centerLabel = isSectionSelected
        ? '${entries[_touchedIndex].value.toInt()}%'
        : '${total.toInt()}';
    final centerSub = isSectionSelected
        ? entries[_touchedIndex].key
        : 'Total';

    return GlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threat Distribution',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Classification breakdown by type',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasData && entries.isNotEmpty)
                Text(
                  '${entries.length} types',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          if (!hasData)
            const ChartEmptyState(
              title: 'No Classified Threats',
              description: 'Threat distribution analytics awaiting telemetry data.',
              icon: Icons.pie_chart_outline_rounded,
              height: 120,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Donut chart with animated center ─────────────────
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                } else {
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                }
                              });
                            },
                          ),
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          startDegreeOffset: -90,
                          sections: entries.asMap().entries.map((item) {
                            final idx = item.key;
                            final entry = item.value;
                            final color = palette[idx % palette.length];
                            final isTouched = _touchedIndex == idx;
                            return PieChartSectionData(
                              color: color,
                              value: entry.value,
                              title: '',            // no cramped % labels
                              radius: isTouched ? 28 : 22,
                              borderSide: isTouched
                                  ? BorderSide(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ),
                      // Center label — animated on touch
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          key: ValueKey(centerLabel),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              centerLabel,
                              style: TextStyle(
                                fontSize: isSectionSelected ? 18 : 16,
                                fontWeight: FontWeight.w800,
                                color: isSectionSelected
                                    ? palette[_touchedIndex % palette.length]
                                    : colors.textPrimary,
                                letterSpacing: -0.6,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              centerSub,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary
                                    .withValues(alpha: 0.65),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ── Premium legend with progress bars ─────────────────
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.asMap().entries.map((item) {
                      final idx = item.key;
                      final entry = item.value;
                      final color = palette[idx % palette.length];
                      final isTouched = _touchedIndex == idx;
                      final pct = total > 0 ? entry.value / total : 0.0;

                      return GestureDetector(
                        onTap: () => setState(
                            () => _touchedIndex = isTouched ? -1 : idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Color dot
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isTouched ? 9 : 7,
                                    height: isTouched ? 9 : 7,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      boxShadow: isTouched
                                          ? [
                                              BoxShadow(
                                                color: color
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isTouched
                                            ? colors.textPrimary
                                            : colors.textPrimary
                                                .withValues(alpha: 0.80),
                                        fontWeight: isTouched
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isTouched
                                          ? color
                                          : colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 3,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.07)
                                      : Colors.black.withValues(alpha: 0.05),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    isTouched
                                        ? color
                                        : color.withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 3. Premium Targeted Decoy Ports Chart — interactive gradient bars + ranked port list
class ProtocolActivityBarChart extends StatefulWidget {
  final Map<String, double>? protocolData;
  const ProtocolActivityBarChart({super.key, this.protocolData});

  @override
  State<ProtocolActivityBarChart> createState() =>
      _ProtocolActivityBarChartState();
}

class _ProtocolActivityBarChartState extends State<ProtocolActivityBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasData = widget.protocolData != null &&
        widget.protocolData!.isNotEmpty;
    final entries = widget.protocolData?.entries.toList() ?? [];
    final maxVal = hasData ? entries.map((e) => e.value).reduce(math.max) : 50.0;
    final calculatedMaxY = maxVal > 0 ? (maxVal * 1.30).ceilToDouble() : 50.0;

    // Find the top port
    final topEntry = hasData
        ? entries.reduce((a, b) => a.value >= b.value ? a : b)
        : null;

    // Cohesive, disciplined palette per bar
    final barColors = [
      colors.brandPrimary,
      const Color(0xFF64D2FF),
      const Color(0xFF5E5CE6),
      colors.brandSecondary,
      colors.warning,
      colors.critical,
    ];

    return GlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Targeted Decoy Ports',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hit count per honeypot port',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Most-hit — clean inline label, no box
              if (topEntry != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: colors.critical.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      topEntry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.critical,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Chart ─────────────────────────────────────────────────
          if (!hasData)
            const ChartEmptyState(
              title: 'No Port Traffic',
              description: 'Honeypot port interactions will appear here.',
              icon: Icons.bar_chart_rounded,
              height: 130,
            )
          else ...[
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: calculatedMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.spot != null &&
                            event.isInterestedForInteractions) {
                          _touchedIndex = response!.spot!.touchedBarGroupIndex;
                        } else {
                          _touchedIndex = -1;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => isDark
                          ? const Color(0xFF1A2840)
                          : Colors.white,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final key = entries[groupIndex].key;
                        return BarTooltipItem(
                          '${rod.toY.toInt()}',
                          TextStyle(
                            color: barColors[groupIndex % barColors.length],
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: '\n$key',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final isTouched = _touchedIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              entries[idx].value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isTouched
                                    ? barColors[idx % barColors.length]
                                    : colors.textSecondary
                                        .withValues(alpha: 0.55),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final isTouched = _touchedIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              entries[idx].key,
                              style: TextStyle(
                                color: isTouched
                                    ? barColors[idx % barColors.length]
                                    : colors.textSecondary,
                                fontWeight: isTouched
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 9.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: calculatedMaxY / 3,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((item) {
                    final idx = item.key;
                    final val = item.value.value;
                    final color = barColors[idx % barColors.length];
                    final isTouched = _touchedIndex == idx;

                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color.withValues(alpha: isTouched ? 1.0 : 0.75),
                              color.withValues(alpha: isTouched ? 0.85 : 0.50),
                            ],
                          ),
                          width: isTouched ? 18 : 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculatedMaxY,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.03),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Ranked row legend (bare, no pills) ─────────────────────
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: entries.asMap().entries.map((item) {
                final idx = item.key;
                final entry = item.value;
                final color = barColors[idx % barColors.length];
                final isTouched = _touchedIndex == idx;
                final rank = idx + 1;

                return GestureDetector(
                  onTap: () => setState(
                      () => _touchedIndex = isTouched ? -1 : idx),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: isTouched
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '#$rank ${entry.key}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isTouched
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isTouched
                              ? colors.textPrimary
                              : colors.textPrimary
                                  .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isTouched ? color : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}


