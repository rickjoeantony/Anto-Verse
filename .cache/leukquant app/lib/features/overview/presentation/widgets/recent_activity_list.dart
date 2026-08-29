// lib/features/overview/presentation/widgets/recent_activity_list.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../domain/overview_summary.dart';

/// Premium Recent Events — luxury iOS timeline style, bare indicators (no pills).
class RecentActivityList extends StatelessWidget {
  final List<OverviewActivityItem> activities;
  final bool isBackendConnected;

  const RecentActivityList({
    super.key,
    required this.activities,
    required this.isBackendConnected,
  });

  Color _severityColor(AppColorScheme colors, String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return colors.critical;
      case 'high':
        return colors.high;
      case 'warning':
      case 'medium':
        return colors.warning;
      case 'success':
      case 'healthy':
        return colors.success;
      default:
        return colors.brandSecondary;
    }
  }

  String _severityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return 'CRITICAL';
      case 'high':     return 'HIGH';
      case 'warning':  return 'WARNING';
      case 'success':  return 'RESOLVED';
      case 'healthy':  return 'HEALTHY';
      default:         return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayItems = activities.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Events',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activities.length} signals captured across decoy perimeter',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // View all link
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/events');
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.brandPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Empty state ─────────────────────────────────────────────
        if (activities.isEmpty)
          const EmptyStateView(
            icon: Icons.history_rounded,
            title: 'No Recent Events',
            description: 'Recent security signals will appear here automatically.',
            isCard: true,
          )

        // ── Timeline Card ───────────────────────────────────────────
        else
          GlassContainer(
            borderRadius: 24,
            blurSigma: 14,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: List.generate(displayItems.length, (index) {
                final item = displayItems[index];
                final isLast = index == displayItems.length - 1;
                final severityColor =
                    _severityColor(colors, item.severity.name);
                final label = _severityLabel(item.severity.name);

                return _ActivityRow(
                  item: item,
                  severityColor: severityColor,
                  severityLabel: label,
                  isLast: isLast,
                  isDark: isDark,
                  colors: colors,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.go('/events');
                  },
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final OverviewActivityItem item;
  final Color severityColor;
  final String severityLabel;
  final bool isLast;
  final bool isDark;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.item,
    required this.severityColor,
    required this.severityLabel,
    required this.isLast,
    required this.isDark,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isJustNow = item.timestamp.toLowerCase().contains('just now');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Timeline dot + glowing connector ─────────────────
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        width: 8.5,
                        height: 8.5,
                        decoration: BoxDecoration(
                          color: severityColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: severityColor.withValues(alpha: 0.65),
                              blurRadius: 7,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1.5,
                          height: 52,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.white.withValues(alpha: 0.02),
                                    ]
                                  : [
                                      Colors.black.withValues(alpha: 0.08),
                                      Colors.black.withValues(alpha: 0.02),
                                    ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── Event content ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top meta: bare severity label + bare protocol + bare timestamp (no pills)
                      Row(
                        children: [
                          Text(
                            severityLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: severityColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '·',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.protocol,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary.withValues(alpha: 0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          // Timestamp — clean bare text with live dot if "Just now"
                          if (isJustNow)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: colors.brandPrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.brandPrimary
                                            .withValues(alpha: 0.65),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Just now',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: colors.brandPrimary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              item.timestamp,
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textSecondary
                                    .withValues(alpha: 0.60),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Event title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          fontSize: 13.5,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2.5),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          color: colors.textSecondary
                              .withValues(alpha: isDark ? 0.65 : 0.75),
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isLast ? 10 : 0),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Trailing Chevron ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colors.textSecondary.withValues(alpha: 0.30),
                  ),
                ),
              ],
            ),

            // Divider between rows (except last)
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 4),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
