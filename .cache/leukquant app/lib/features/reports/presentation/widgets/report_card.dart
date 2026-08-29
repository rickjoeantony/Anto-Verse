// lib/features/reports/presentation/widgets/report_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../domain/report_item.dart';

/// Clean, luxury iOS report card with bare indicators, specular glass, and download action.
class ReportCard extends StatelessWidget {
  final ReportItem report;

  const ReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon + Title + Periodicity ────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description_outlined,
                size: 22,
                color: colors.brandPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontSize: 15.5,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      report.coveragePeriod,
                      style: TextStyle(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Bare periodicity
              Text(
                report.periodicity,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────
          Text(
            report.description,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: isDark ? 0.75 : 0.85),
              height: 1.45,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 14),

          // ── Details Summary Row (Clean Inset Block) ────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : colors.brandPrimary.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : colors.border.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Format', report.format, colors),
                _buildStatItem(
                  'Status',
                  report.isReady ? 'Ready' : 'Pending',
                  colors,
                  statusColor: report.isReady ? colors.success : colors.warning,
                ),
                _buildStatItem('ID', report.id, colors, isMono: true),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Download / Export Action ───────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: report.isReady
                  ? () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading ${report.title}...'),
                          backgroundColor: colors.brandPrimary,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: Icon(
                report.isReady ? Icons.download_rounded : Icons.hourglass_empty_rounded,
                size: 16,
                color: report.isReady ? colors.brandPrimary : colors.textSecondary.withValues(alpha: 0.5),
              ),
              label: Text(
                report.isReady ? 'Download Report' : 'Report Compilation Pending',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: report.isReady ? colors.brandPrimary : colors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(
                  color: report.isReady
                      ? colors.brandPrimary.withValues(alpha: 0.4)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : colors.border),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    AppColorScheme colors, {
    Color? statusColor,
    bool isMono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colors.textSecondary.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusColor != null) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4.5),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: statusColor ?? colors.textPrimary,
                fontFamily: isMono ? 'monospace' : null,
                letterSpacing: isMono ? 0.2 : -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
