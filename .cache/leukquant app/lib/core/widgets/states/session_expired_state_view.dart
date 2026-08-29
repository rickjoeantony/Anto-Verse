// lib/core/widgets/states/session_expired_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable Session Expired / 401 Unauthorized State View for LeukQuant Mobile.
class SessionExpiredStateView extends StatelessWidget {
  final String title;
  final String message;
  final String sessionExpiryReason;
  final VoidCallback? onReauthenticate;
  final VoidCallback? onSwitchAccount;
  final bool isCard;
  final bool useIllustration;

  const SessionExpiredStateView({
    super.key,
    this.title = 'Session Expired',
    this.message = 'Your security session has timed out due to enterprise inactivity policies. Re-authenticate to resume monitoring.',
    this.sessionExpiryReason = 'JWT Token Expired • 30m Inactivity Timeout',
    this.onReauthenticate,
    this.onSwitchAccount,
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
            const SessionExpiredIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.timer_off_rounded, size: 36, color: Colors.purple),
            ),
          ],
          const SizedBox(height: 18),

          // Expiry Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 12, color: Colors.purple),
                const SizedBox(width: 6),
                Text(
                  sessionExpiryReason,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.purple,
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

          // Actions
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onReauthenticate,
                icon: const Icon(Icons.fingerprint_rounded, size: 20),
                label: const Text('Unlock with Biometrics / SSO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (onSwitchAccount != null)
                OutlinedButton.icon(
                  onPressed: onSwitchAccount,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Switch Account'),
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
