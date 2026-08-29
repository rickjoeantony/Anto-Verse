// lib/features/settings/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass/liquid_glass_card.dart';
import '../../../core/widgets/ios26_switch.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../providers/settings_provider.dart';
import 'widgets/profile_card.dart';
import 'widgets/theme_selector_tile.dart';

/// Settings screen for workspace preferences, themes, alerts, and profile.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of this security workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.critical,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    final inAppAlerts = ref.watch(inAppAlertsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Settings',
        subtitle: 'Workspace & App Preferences',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            ProfileCard(profile: profile)
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0, duration: 350.ms),
            const SizedBox(height: 14),

            // Theme Mode Selector
            const ThemeSelectorTile()
                .animate()
                .fadeIn(duration: 350.ms, delay: 50.ms),
            const SizedBox(height: 14),

            // Notification & Alerts Preferences
            LiquidGlassCard(
              cornerRadius: 24.0,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.brandPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.notifications_outlined, size: 18, color: colors.brandPrimary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Notifications & Alerts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // In-App Alert Preference Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In-App Security Alerts',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Show contextual notifications for high and critical events while active in app.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Ios26Switch(
                        value: inAppAlerts,
                        onChanged: (val) {
                          ref.read(inAppAlertsProvider.notifier).setInAppAlerts(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Push Notification Channel Registration
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push Notifications',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enterprise push channel registration status.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppConstants.pushServicePending,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
            const SizedBox(height: 14),

            // Application Information
            LiquidGlassCard(
              cornerRadius: 24.0,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Version', AppConstants.appVersion, colors, theme),
                  _buildInfoRow('Platform', 'Android First · Material 3', colors, theme),
                  _buildInfoRow('Engine Mode', 'Real Staging API Client', colors, theme),
                  _buildInfoRow('Admin Portal', 'Web Portal Only (Restricted)', colors, theme),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 150.ms),
            const SizedBox(height: 20),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showSignOutDialog(context, ref),
                icon: Icon(Icons.logout_rounded, size: 18, color: colors.critical),
                label: Text(
                  'Sign Out of Workspace',
                  style: TextStyle(
                    color: colors.critical,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.critical.withValues(alpha: 0.4)),
                  backgroundColor: colors.critical.withValues(alpha: 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 200.ms),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                AppConstants.copyright,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    AppColorScheme colors,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
