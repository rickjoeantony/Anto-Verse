// lib/features/incidents/presentation/widgets/incident_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../../core/widgets/incident_timeline_stepper.dart';
import '../../../events/domain/severity_level.dart';
import '../../domain/incident.dart';

/// Premium Incident Card — clean hierarchy, bare status indicators, expandable audit timeline.
class IncidentCard extends StatefulWidget {
  final Incident incident;

  const IncidentCard({super.key, required this.incident});

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final incident = widget.incident;

    final severityColor = switch (incident.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high => colors.high,
      SeverityLevel.warning => colors.warning,
      SeverityLevel.low => colors.brandPrimary,
      SeverityLevel.healthy => colors.success,
      SeverityLevel.success => colors.success,
      SeverityLevel.info => colors.brandSecondary,
    };

    final severityLabel = switch (incident.severity) {
      SeverityLevel.critical => 'Critical',
      SeverityLevel.high => 'High',
      SeverityLevel.warning => 'Warning',
      SeverityLevel.low => 'Low',
      SeverityLevel.healthy => 'Resolved',
      SeverityLevel.success => 'Resolved',
      SeverityLevel.info => 'Info',
    };

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top meta row: dot + severity + ID + status ────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing severity dot
              Container(
                width: 7.5,
                height: 7.5,
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
              const SizedBox(width: 7),
              Text(
                severityLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: severityColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '·',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  incident.id,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary.withValues(alpha: 0.65),
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Bare status with dot
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
                          color: colors.brandPrimary.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4.5),
                  Text(
                    incident.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.brandPrimary,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Incident title ─────────────────────────────────────────
          Text(
            incident.title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              fontSize: 16,
              letterSpacing: -0.4,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          // ── Attack Telemetry Badges (IP, Port, Blocked) ────────────
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Attacker IP & Location
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public_rounded, size: 12, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${incident.sourceIp} (${incident.country})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Port & Protocol
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${incident.protocol}:${incident.targetPort}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
              ),

              // Blocked / Contained Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: incident.isBlocked
                      ? colors.success.withValues(alpha: 0.12)
                      : colors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: incident.isBlocked
                        ? colors.success.withValues(alpha: 0.4)
                        : colors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      incident.isBlocked ? Icons.gpp_good_rounded : Icons.shield_outlined,
                      size: 12,
                      color: incident.isBlocked ? colors.success : colors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      incident.isBlocked ? 'Honeypot Blocked' : 'Triage Active',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: incident.isBlocked ? colors.success : colors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Description ────────────────────────────────────────────
          Text(
            incident.description,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: isDark ? 0.75 : 0.85),
              height: 1.45,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 14),

          // ── Recommended action — clean card block ──────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : colors.brandPrimary.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : colors.border.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: colors.brandPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Action',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary.withValues(alpha: 0.7),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        incident.recommendedAction,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textPrimary,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Stepper toggle ─────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    size: 15,
                    color: colors.brandSecondary.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Audit Timeline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.brandSecondary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IncidentTimelineStepper(
                      timeline: incident.timeline,
                      status: incident.status,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
