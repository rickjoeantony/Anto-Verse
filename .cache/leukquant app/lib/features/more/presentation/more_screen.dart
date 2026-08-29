// lib/features/more/presentation/more_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../settings/presentation/widgets/notifications_settings_tile.dart';
import '../../settings/presentation/widgets/profile_card.dart';
import '../../settings/presentation/widgets/theme_selector_tile.dart';
import '../../settings/providers/settings_provider.dart';

/// Consolidated More screen with iOS Settings-style grouped glass lists.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            // iOS Large Title
            Text(
              'Settings & More',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: colors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Workspace preferences and security profile',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 20),

            // User Profile Card
            ProfileCard(profile: profile),
            const SizedBox(height: 20),

            // GROUP 1: Security Workspace
            _buildSectionHeader('SECURITY WORKSPACE', colors),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 24.0,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsRow(
                    context,
                    icon: Icons.description_outlined,
                    iconColor: colors.brandPrimary,
                    title: 'Reports & Briefs',
                    subtitle: 'Compliance exports and SOC 2 telemetry',
                    onTap: () => context.push('/more/reports'),
                    colors: colors,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                  _buildSettingsRow(
                    context,
                    icon: Icons.cloud_done_outlined,
                    iconColor: colors.brandSecondary,
                    title: 'Protected Deployments',
                    subtitle: 'Active decoy sensor nodes and regions',
                    onTap: () => context.push('/more/deployments'),
                    colors: colors,
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            // GROUP 2: Preferences
            _buildSectionHeader('PREFERENCES', colors),
            const SizedBox(height: 8),
            const ThemeSelectorTile(),
            const SizedBox(height: 12),
            const NotificationsSettingsTile(),
            const SizedBox(height: 20),

            // GROUP 3: Support & About
            _buildSectionHeader('SUPPORT & ABOUT', colors),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 24.0,
              padding: const EdgeInsets.all(18.0),
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
                        child: Icon(Icons.info_outline_rounded, size: 18, color: colors.brandPrimary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'About LeukQuant',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow('Version', AppConstants.appVersion, colors),
                  _buildInfoRow('Engine', 'LeukQuant Autonomous Defense v2026', colors),
                  _buildInfoRow('Platform', 'iOS-Native Glass Architecture', colors),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            GestureDetector(
              onTap: () => _showSignOutDialog(context, ref),
              child: GlassCard(
                borderRadius: 18.0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: colors.critical),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out of Workspace',
                        style: TextStyle(
                          color: colors.critical,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Center(
              child: Text(
                AppConstants.copyright,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.6),
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

  Widget _buildSectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppColorScheme colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            fontSize: 14.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: colors.textSecondary.withValues(alpha: 0.7),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
