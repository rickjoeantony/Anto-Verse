// lib/features/overview/presentation/widgets/deployment_health_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_card.dart';
import '../../../../core/widgets/glass/liquid_glass_badge.dart';

/// Customer-friendly status card answering: "Is my protection active?" in Liquid Glass.
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

    // Determine title, subtitle, badge, and color based strictly on verified backend state
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

    return LiquidGlassCard(
      cornerRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.65),
                      blurRadius: 7,
                    ),
                  ],
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
              LiquidGlassBadge(
                label: statusLabel,
                color: accentColor,
                showDot: false,
                fontSize: 11,
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
