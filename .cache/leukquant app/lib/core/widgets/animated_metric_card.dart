// lib/core/widgets/animated_metric_card.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean, highly premium enterprise metric card for dashboard overview.
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
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayValue = isPending
        ? '—'
        : (count != null ? count.toString() : (stringValue ?? '—'));

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.border.withValues(alpha: 0.8)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0x0C2563EB),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              if (!isPending && count != null && count! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayValue,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: colors.textPrimary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
