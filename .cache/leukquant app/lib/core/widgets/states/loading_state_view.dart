// lib/core/widgets/states/loading_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable cyber loading & telemetry sync state for LeukQuant Mobile.
class LoadingStateView extends StatelessWidget {
  final String title;
  final String message;
  final List<String>? telemetrySteps;
  final int activeStepIndex;
  final bool isCard;
  final bool useIllustration;

  const LoadingStateView({
    super.key,
    this.title = 'Synchronizing Security Mesh',
    this.message = 'Retrieving real-time decoy telemetry and honeytoken triggers...',
    this.telemetrySteps = const [
      'Establishing TLS 1.3 encrypted tunnel',
      'Querying active honeypot mesh',
      'Verifying telemetry signature digests',
    ],
    this.activeStepIndex = 1,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radar scanner or circular indicator
            if (useIllustration) ...[
              const LoadingStateIllustration(size: 150),
            ] else ...[
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.brandPrimary),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Telemetry Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.brandPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TELEMETRY SYNC IN PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.brandPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Step Progress Checklist
            if (telemetrySteps != null && telemetrySteps!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: List.generate(telemetrySteps!.length, (index) {
                    final isCompleted = index < activeStepIndex;
                    final isCurrent = index == activeStepIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          if (isCompleted)
                            Icon(Icons.check_circle_rounded, size: 15, color: colors.success)
                          else if (isCurrent)
                            SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colors.brandPrimary),
                              ),
                            )
                          else
                            Icon(Icons.circle_outlined, size: 14, color: colors.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              telemetrySteps![index],
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                color: isCompleted || isCurrent ? colors.textPrimary : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );

    if (isCard) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? colors.border.withValues(alpha: 0.8) : colors.border),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }
}
