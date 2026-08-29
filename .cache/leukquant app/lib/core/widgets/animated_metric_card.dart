// lib/core/widgets/animated_metric_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'glass/glass_container.dart';

/// Premium metric card with Plus Jakarta Sans typography and bare status indicator.
class AnimatedMetricCard extends StatelessWidget {
  final String title;
  final int? count;
  final String? stringValue;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isPending;

  const AnimatedMetricCard({
    super.key,
    required this.title,
    this.count,
    this.stringValue,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool hasData = !isPending && (count != null || stringValue != null);
    final String displayValue =
        hasData ? (count != null ? count.toString() : stringValue!) : '—';
    final String displaySubtitle = hasData ? subtitle : 'No data';
    final bool isAlert = hasData && count != null && count! > 0;
    final bool isLiveTime = hasData &&
        stringValue != null &&
        displayValue.toLowerCase().contains('just now');

    final double valueFontSize = displayValue.length > 5
        ? (displayValue.length > 8 ? 19.0 : 21.0)
        : 30.0;

    return GlassContainer(
      borderRadius: 22.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top row: bare icon left, live indicator / alert dot right ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 20,
                color: accentColor.withValues(alpha: isDark ? 0.85 : 0.75),
              ),
              if (isLiveTime)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.success.withValues(alpha: 0.65),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      'Live',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.success,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                )
              else if (isAlert)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.60),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Large numeral or styled string value ──────────────────────
          SizedBox(
            height: 34,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                displayValue,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: valueFontSize,
                  color: isLiveTime ? colors.brandPrimary : colors.textPrimary,
                  letterSpacing: displayValue.length > 5 ? -0.3 : -0.8,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Card label ────────────────────────────────────────────────
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: colors.textPrimary.withValues(alpha: 0.88),
              letterSpacing: -0.1,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // ── Subtitle ──────────────────────────────────────────────────
          Text(
            displaySubtitle,
            style: GoogleFonts.plusJakartaSans(
              color: colors.textSecondary.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
