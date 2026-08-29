// lib/core/widgets/states/success_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable Success State View with verification metrics for LeukQuant Mobile.
class SuccessStateView extends StatelessWidget {
  final String title;
  final String message;
  final String? badgeLabel;
  final Map<String, String>? summaryMetrics;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool isCard;
  final bool useIllustration;

  const SuccessStateView({
    super.key,
    this.title = 'Decoy Node Deployed Successfully',
    this.message = 'The security decoy has been provisioned, bound to the honeypot mesh, and is actively capturing adversarial probe traffic.',
    this.badgeLabel = 'DEPLOYMENT CONFIRMED • ACTIVE',
    this.summaryMetrics = const {
      'Decoy ID': 'LKQ-DECOY-88492',
      'Target IP': '10.24.180.12/24',
      'Protocol': 'SSH (Port 2222)',
      'Telemetry Latency': '14 ms',
      'Signature Status': 'Cryptographically Signed (Ed25519)',
    },
    this.primaryActionLabel = 'View in Decoy Fleet',
    this.onPrimaryAction,
    this.secondaryActionLabel = 'Return to Overview',
    this.onSecondaryAction,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration
          if (useIllustration) ...[
            const SuccessStateIllustration(size: 160)
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: colors.success.withValues(alpha: 0.35)),
              ),
              child: Icon(Icons.check_circle_outline_rounded, size: 40, color: colors.success),
            ),
          ],
          const SizedBox(height: 18),

          // Status Badge
          if (badgeLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, size: 13, color: colors.success),
                  const SizedBox(width: 6),
                  Text(
                    badgeLabel!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.success,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
          ],

          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17.5,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),

          // Message
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 200.ms),

          // Summary Metrics Card
          if (summaryMetrics != null && summaryMetrics!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: summaryMetrics!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 250.ms),
          ],

          // Actions
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (onPrimaryAction != null)
                ElevatedButton.icon(
                  onPressed: onPrimaryAction,
                  icon: const Icon(Icons.hub_outlined, size: 18),
                  label: Text(primaryActionLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: colors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                OutlinedButton.icon(
                  onPressed: onSecondaryAction,
                  icon: const Icon(Icons.dashboard_outlined, size: 18),
                  label: Text(secondaryActionLabel!),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    side: BorderSide(color: colors.border),
                    foregroundColor: colors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
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

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      ),
    );
  }
}
