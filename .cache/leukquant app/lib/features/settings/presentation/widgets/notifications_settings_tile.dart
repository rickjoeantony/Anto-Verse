// lib/features/settings/presentation/widgets/notifications_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

/// Interactive Alert & Notification configuration card with live Alert Simulator.
class NotificationsSettingsTile extends ConsumerWidget {
  const NotificationsSettingsTile({super.key});

  void _triggerTestAlert(BuildContext context, AlertTone tone) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        content: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.critical.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.critical.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.critical.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_active_rounded, color: colors.critical, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🚨 CRITICAL CANARY ALERT',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colors.critical,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Tone: ${tone.title}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Decoy SSH-HONEYPOT-01 intercepted credential attempt from 198.51.100.42.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNotificationAccess = ref.watch(notificationAccessProvider);
    final currentTone = ref.watch(alertToneProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.notifications_active_outlined, size: 20, color: colors.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts & Notification Access',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure push telemetry tones & canary alerts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notification Access Toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasNotificationAccess ? 'Permission granted' : 'Notifications disabled',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasNotificationAccess ? colors.success : colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: hasNotificationAccess,
                  activeColor: colors.brandPrimary,
                  onChanged: (val) {
                    ref.read(notificationAccessProvider.notifier).togglePermission(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alert Tone Selector
          Text(
            'Security Alert Tone',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Tone Options List
          ...AlertTone.values.map((tone) {
            final isSelected = tone == currentTone;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.brandPrimary.withValues(alpha: isDark ? 0.12 : 0.06)
                    : colors.surfaceMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? colors.brandPrimary.withValues(alpha: 0.4)
                      : colors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? colors.brandPrimary : colors.textSecondary,
                  size: 18,
                ),
                title: Text(
                  tone.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  tone.description,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
                onTap: () {
                  ref.read(alertToneProvider.notifier).setTone(tone);
                },
              ),
            );
          }),
          const SizedBox(height: 12),

          // Interactive "Test Alert Simulation" Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _triggerTestAlert(context, currentTone),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
              label: const Text(
                'Test Alert Simulation',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
