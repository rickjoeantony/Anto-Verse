// lib/features/more/presentation/more_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../settings/presentation/widgets/notifications_settings_tile.dart';
import '../../settings/presentation/widgets/profile_card.dart';
import '../../settings/presentation/widgets/theme_selector_tile.dart';
import '../../settings/providers/settings_provider.dart';

/// Consolidated More screen providing access to Reports, Deployments,
/// Notifications, Appearance, Support, and Sign Out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your security workspace?'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'More',
        subtitle: 'Workspace, Reports & Settings',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
          children: [
            // User Profile Card
            ProfileCard(profile: profile),
            const SizedBox(height: 16),

            // Management & Features Group
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildNavTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Reports & Audit Briefs',
                    subtitle: 'Executive summaries and compliance exports',
                    onTap: () => context.push('/more/reports'),
                    colors: colors,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? colors.border.withValues(alpha: 0.6) : colors.border,
                  ),
                  _buildNavTile(
                    context,
                    icon: Icons.cloud_done_outlined,
                    title: 'Protected Deployments',
                    subtitle: 'Sensor health and coverage status',
                    onTap: () => context.push('/more/deployments'),
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Appearance & Themes Group
            const ThemeSelectorTile(),
            const SizedBox(height: 16),

            // Notifications, Push Alert Tone & Live Tester
            const NotificationsSettingsTile(),
            const SizedBox(height: 16),

            // Help & Information
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Version', AppConstants.appVersion, colors),
                  _buildInfoRow('Environment', 'Staging Client (middle-man-3)', colors),
                  _buildInfoRow('Platform', 'Android Security Mobile Client', colors),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sign Out Action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showSignOutDialog(context, ref),
                icon: Icon(Icons.logout_rounded, size: 18, color: colors.critical),
                label: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: colors.critical,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.critical.withValues(alpha: 0.4)),
                  backgroundColor: colors.critical.withValues(alpha: 0.04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                AppConstants.copyright,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppColorScheme colors,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.brandPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 20, color: colors.brandPrimary),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary, fontSize: 14.5),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: colors.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        ],
      ),
    );
  }
}
