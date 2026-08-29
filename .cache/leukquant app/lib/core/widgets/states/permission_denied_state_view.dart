// lib/core/widgets/states/permission_denied_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable Permission Denied / 403 Forbidden Access State View for LeukQuant Mobile.
class PermissionDeniedStateView extends StatelessWidget {
  final String title;
  final String message;
  final String currentRole;
  final String requiredRole;
  final String? resourceName;
  final VoidCallback? onRequestElevation;
  final VoidCallback? onReturn;
  final bool isCard;
  final bool useIllustration;

  const PermissionDeniedStateView({
    super.key,
    this.title = 'Access Restricted: SOC Clearance Required',
    this.message = 'Modifying decoy node topologies and deploying honeytokens requires elevated cryptographic authorization.',
    this.currentRole = 'SOC Analyst (Level 1)',
    this.requiredRole = 'SOC Admin / Decoy Commander (Level 3)',
    this.resourceName = 'Decoy Fleet Infrastructure & Honeytoken Rotator',
    this.onRequestElevation,
    this.onReturn,
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
            const PermissionDeniedIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.critical.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: colors.critical.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.lock_person_rounded, size: 36, color: colors.critical),
            ),
          ],
          const SizedBox(height: 18),

          // Clearance Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.critical.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.critical.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 12, color: colors.critical),
                const SizedBox(width: 6),
                Text(
                  '403 FORBIDDEN • RBAC ENFORCED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: colors.critical,
                    letterSpacing: 0.5,
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
              fontSize: 17,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
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
          ),

          // Role Comparison Card
          const SizedBox(height: 18),
          Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Role:', style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
                    Text(
                      currentRole,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Required:', style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
                    Text(
                      requiredRole,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.critical),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onRequestElevation,
                icon: const Icon(Icons.verified_user_rounded, size: 18),
                label: const Text('Request SOC Clearance'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (onReturn != null)
                OutlinedButton.icon(
                  onPressed: onReturn,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Return to Overview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    side: BorderSide(color: colors.border),
                    foregroundColor: colors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
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
