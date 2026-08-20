// lib/features/overview/presentation/widgets/deployment_health_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Customer-friendly status card answering: "Is my protection active?"
class DeploymentHealthCard extends StatelessWidget {
  final bool isBackendConnected;
  final bool hasActiveIncident;
  final String? lastTelemetryTime;
  final String? region;

  const DeploymentHealthCard({
    super.key,
    required this.isBackendConnected,
    this.hasActiveIncident = false,
    this.lastTelemetryTime,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    // 1. Determine title, subtitle, badge, and color based strictly on verified backend state
    final (String cardTitle, String statusLabel, String description, Color accentColor) = () {
      if (hasActiveIncident) {
        return (
          'Security Attention Required',
          'Needs Review',
          'High-risk activity detected. Review the latest incident for recommended actions.',
          colors.critical,
        );
      }

      if (!isBackendConnected) {
        return (
          'Ghost-Net Deployment',
          'Awaiting Connection',
          'Connect an active deployment to view verified security status and activity.',
          colors.brandPrimary,
        );
      }

      return (
        'Ghost-Net Deployment',
        'Deployment Connected',
        'Last verified telemetry: ${lastTelemetryTime ?? "Active now"} (Region: ${region ?? "Primary"}).',
        colors.success,
      );
    }();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasActiveIncident
              ? colors.critical.withValues(alpha: 0.4)
              : colors.border,
          width: hasActiveIncident ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasActiveIncident
                ? colors.critical.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cardTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.4,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
