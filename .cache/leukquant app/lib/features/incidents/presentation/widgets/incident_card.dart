// lib/features/incidents/presentation/widgets/incident_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/incident_timeline_stepper.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../events/domain/severity_level.dart';
import '../../domain/incident.dart';

/// Customer-friendly incident card with visual audit stepper.
class IncidentCard extends StatefulWidget {
  final Incident incident;

  const IncidentCard({
    super.key,
    required this.incident,
  });

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final incident = widget.incident;

    final severityColor = switch (incident.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high => colors.high,
      SeverityLevel.warning => colors.warning,
      SeverityLevel.low => colors.brandPrimary,
      SeverityLevel.healthy || SeverityLevel.success => colors.success,
      SeverityLevel.info => colors.brandSecondary,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? colors.border.withValues(alpha: 0.85)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Accent Stripe
            Container(
              height: 3,
              color: severityColor,
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Severity, ID, and Status
                  Row(
                    children: [
                      SeverityBadge(
                        severity: incident.severity,
                        compact: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        incident.id,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          incident.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Incident Title
                  Text(
                    incident.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 15.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Plain Language Description
                  Text(
                    incident.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recommended Action Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, size: 16, color: colors.brandPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RECOMMENDED ACTION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.brandPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                incident.recommendedAction,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textPrimary,
                                  height: 1.35,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Visual Stepper Header & Toggle
            Divider(
              height: 1,
              color: isDark ? colors.border.withValues(alpha: 0.6) : colors.border,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timeline_rounded, size: 16, color: colors.brandSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Audit Progress Stepper',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.brandSecondary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            if (_isExpanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: IncidentTimelineStepper(
                  timeline: incident.timeline,
                  status: incident.status,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
