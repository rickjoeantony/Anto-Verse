// lib/features/overview/presentation/widgets/analytics_charts.dart

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/chart_empty_state.dart';
import '../../../../core/widgets/glass/glass_container.dart';

/// 1. Enhanced Security Activity Line Chart
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
                      'Hourly telemetry across perimeter sensors',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.brandPrimary.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (!hasData)
            const ChartEmptyState(
              title: 'No Telemetry Signal',
              description: 'Real-time telemetry trend data awaiting events.',
              icon: Icons.show_chart_rounded,
              height: 140,
            )
          else ...[
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: calculatedMaxY,
                  minX: 0,
                  maxX: (pts.length - 1).toDouble().clamp(1.0, 100.0),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.lineBarSpots != null &&
                            response!.lineBarSpots!.isNotEmpty &&
                            event.isInterestedForInteractions) {
                          _touchedIndex = response.lineBarSpots!.first.spotIndex;
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => isDark
                          ? const Color(0xFF1A2840)
                          : Colors.white,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final hour = '${spot.spotIndex * 4}:00';
                          return LineTooltipItem(
                            '${spot.y.toInt()} attacks',
                            TextStyle(
                              color: colors.brandPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '\n$hour UTC',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((idx) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: colors.brandPrimary.withValues(alpha: 0.5),
                            strokeWidth: 1.5,
                            dashArray: [4, 4],
                          ),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                              radius: 5,
                              color: colors.brandPrimary,
                              strokeWidth: 2.5,
                              strokeColor: Colors.white,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= pts.length) {
                            return const SizedBox.shrink();
                          }
                          final isSelected = _touchedIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${idx * 4}h',
                              style: TextStyle(
                                color: isSelected
                                    ? colors.brandPrimary
                                    : colors.textSecondary
                                        .withValues(alpha: 0.65),
                                fontSize: 9.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: pts
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: colors.brandPrimary,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final isTop = spot.y == maxVal && maxVal > 0;
                          return FlDotCirclePainter(
                            radius: isTop ? 4.5 : 2.5,
                            color: isTop ? colors.critical : colors.brandPrimary,
                            strokeWidth: 1.5,
                            strokeColor: isDark
                                ? const Color(0xFF0B1020)
                                : Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.brandPrimary.withValues(alpha: 0.22),
                            colors.brandPrimary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'Peak',
                  value: '${maxVal.toInt()}',
                  color: colors.critical,
                  colors: colors,
                ),
                _StatChip(
                  label: 'Avg',
                  value: '${avgVal.toStringAsFixed(1)}',
                  color: colors.brandPrimary,
                  colors: colors,
                ),
                _StatChip(
                  label: 'Min',
                  value: '${minVal.toInt()}',
                  color: colors.textSecondary,
                  colors: colors,
                ),
                _StatChip(
                  label: 'Sensors',
                  value: '3 Active',
                  color: colors.success,
                  colors: colors,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppColorScheme colors;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

// Helpers for Threat Distribution formatting
String _formatThreatLevelName(String key) {
  final lower = key.toLowerCase().trim();
  switch (lower) {
    case '5':
    case 'critical':
    case 'crit':
      return 'Critical (L5)';
    case '4':
    case 'high':
      return 'High (L4)';
    case '3':
    case 'medium':
    case 'med':
      return 'Medium (L3)';
    case '2':
    case 'low':
      return 'Low (L2)';
    case '1':
    case 'info':
      return 'Info (L1)';
    default:
      if (RegExp(r'^\d+$').hasMatch(key)) {
        return 'Level $key';
      }
      return key.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}

Color _getThreatLevelColor(String key, AppColorScheme colors) {
  final lower = key.toLowerCase().trim();
  switch (lower) {
    case '5':
    case 'critical':
      return colors.critical;
    case '4':
    case 'high':
      return colors.high;
    case '3':
    case 'medium':
      return colors.warning;
    case '2':
    case 'low':
      return colors.brandPrimary;
    case '1':
    case 'info':
      return const Color(0xFF64D2FF);
    default:
      return colors.brandSecondary;
  }
}

// Helpers for Protocol / Targeted Ports formatting
String _canonicalPortKey(String raw) {
  final lower = raw.toLowerCase().trim();
  if (lower.contains('ssh') || lower.contains('brute_force') || lower == '22') {
    return 'SSH';
  }
  if (lower.contains('http') || lower.contains('credential') || lower.contains('stuffing') || lower == '80') {
    return 'HTTP';
  }
  if (lower.contains('ddos') || lower.contains('udp') || lower.contains('flood')) {
    return 'DDoS';
  }
  if (lower.contains('injection') || lower.contains('sql') || lower == '3306' || lower == '5432') {
    return 'SQLi';
  }
  if (lower.contains('xss') || lower.contains('https') || lower == '443') {
    return 'XSS';
  }
  if (lower.contains('rdp') || lower == '3389') {
    return 'RDP';
  }
  if (lower.contains('ftp') || lower == '21') {
    return 'FTP';
  }
  if (lower.contains('dns') || lower == '53') {
    return 'DNS';
  }
  return raw.toUpperCase();
}

String _formatShortPortName(String raw) {
  return _canonicalPortKey(raw);
}

String _formatFullPortName(String raw) {
  final canonical = _canonicalPortKey(raw);
  switch (canonical) {
    case 'SSH':
      return 'SSH (Port 22)';
    case 'HTTP':
      return 'HTTP (Port 80)';
    case 'DDoS':
      return 'DDoS (UDP)';
    case 'SQLi':
      return 'SQL Injection (3306)';
    case 'XSS':
      return 'Web / XSS (443)';
    case 'RDP':
      return 'RDP (Port 3389)';
    case 'FTP':
      return 'FTP (Port 21)';
    case 'DNS':
      return 'DNS (Port 53)';
    default:
      return canonical;
  }
}

/// 2. Threat Distribution Donut Chart
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

    final hasData = widget.threatData != null && widget.threatData!.isNotEmpty;
    final entries = widget.threatData?.entries.toList() ?? [];
    final total = hasData
        ? entries.fold(0.0, (sum, e) => sum + e.value)
        : 0.0;

    final isSectionSelected = _touchedIndex >= 0 && _touchedIndex < entries.length;
    final selectedPct = isSectionSelected && total > 0
        ? '${((entries[_touchedIndex].value / total) * 100).toStringAsFixed(0)}%'
        : null;
    final centerLabel = isSectionSelected
        ? '${entries[_touchedIndex].value.toInt()}'
        : '${total.toInt()}';
    final centerSub = isSectionSelected
        ? '${_formatThreatLevelName(entries[_touchedIndex].key)} ($selectedPct)'
        : 'Total';

    return GlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              description: 'Real-time honeypot threat levels will appear here.',
              icon: Icons.pie_chart_outline_rounded,
              height: 130,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                            final color = _getThreatLevelColor(entry.key, colors);
                            final isTouched = _touchedIndex == idx;
                            return PieChartSectionData(
                              color: color,
                              value: entry.value,
                              title: '',
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
                                    ? _getThreatLevelColor(entries[_touchedIndex].key, colors)
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
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary
                                    .withValues(alpha: 0.75),
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

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.asMap().entries.map((item) {
                      final idx = item.key;
                      final entry = item.value;
                      final color = _getThreatLevelColor(entry.key, colors);
                      final isTouched = _touchedIndex == idx;
                      final pct = total > 0 ? (entry.value / total) : 0.0;
                      final pctText = '${(pct * 100).toStringAsFixed(0)}%';

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
                                      _formatThreatLevelName(entry.key),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isTouched
                                            ? colors.textPrimary
                                            : colors.textPrimary
                                                .withValues(alpha: 0.85),
                                        fontWeight: isTouched
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.toInt()} ($pctText)',
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: pct),
                                  duration: const Duration(milliseconds: 600),
                                  builder: (context, val, _) =>
                                      LinearProgressIndicator(
                                    value: val,
                                    minHeight: isTouched ? 4 : 3,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
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

/// 3. Premium Targeted Decoy Ports Chart â€” zero text overlap with compact labels
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

    // Normalize and aggregate by canonical port key to guarantee NO DUPLICATES
    final Map<String, double> normalizedData = {};
    if (widget.protocolData != null) {
      for (final entry in widget.protocolData!.entries) {
        final key = _canonicalPortKey(entry.key);
        normalizedData[key] = (normalizedData[key] ?? 0.0) + entry.value;
      }
    }

    final hasData = normalizedData.isNotEmpty;
    final entries = normalizedData.entries.toList();
    final maxVal = hasData ? entries.map((e) => e.value).reduce(math.max) : 5.0;
    final calculatedMaxY = maxVal > 0 ? (maxVal * 1.35).ceilToDouble() : 5.0;

    final topEntry = hasData
        ? entries.reduce((a, b) => a.value >= b.value ? a : b)
        : null;

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
              if (topEntry != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.critical.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.critical.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 13,
                        color: colors.critical,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatShortPortName(topEntry.key),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.critical,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

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
                        final fullName = _formatFullPortName(entries[groupIndex].key);
                        return BarTooltipItem(
                          '${rod.toY.toInt()} hits',
                          TextStyle(
                            color: barColors[groupIndex % barColors.length],
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: '\n$fullName',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
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
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final isTouched = _touchedIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              entries[idx].value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isTouched
                                    ? barColors[idx % barColors.length]
                                    : colors.textSecondary
                                        .withValues(alpha: 0.65),
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
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final isTouched = _touchedIndex == idx;
                          final shortLabel = _formatShortPortName(entries[idx].key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              shortLabel,
                              style: TextStyle(
                                color: isTouched
                                    ? barColors[idx % barColors.length]
                                    : colors.textPrimary.withValues(alpha: 0.85),
                                fontWeight: isTouched
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                fontSize: 10.5,
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
                    horizontalInterval: calculatedMaxY > 3 ? calculatedMaxY / 3 : 1,
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
                              color.withValues(alpha: isTouched ? 1.0 : 0.85),
                              color.withValues(alpha: isTouched ? 0.85 : 0.60),
                            ],
                          ),
                          width: isTouched ? 18 : 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
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

            // Ranked row legend with clean badge pills
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: entries.asMap().entries.map((item) {
                final idx = item.key;
                final entry = item.value;
                final color = barColors[idx % barColors.length];
                final isTouched = _touchedIndex == idx;
                final rank = idx + 1;
                final fullName = _formatFullPortName(entry.key);

                return GestureDetector(
                  onTap: () => setState(
                      () => _touchedIndex = isTouched ? -1 : idx),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTouched
                          ? color.withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTouched
                            ? color.withValues(alpha: 0.5)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '#$rank $fullName',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isTouched
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isTouched
                                ? colors.textPrimary
                                : colors.textPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${entry.value.toInt()}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
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