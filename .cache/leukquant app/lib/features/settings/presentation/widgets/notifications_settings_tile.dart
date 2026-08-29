// lib/features/settings/presentation/widgets/notifications_settings_tile.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../../core/widgets/ios26_switch.dart';
import '../../providers/settings_provider.dart';

/// Interactive Alert & Notification configuration card with system sound & permission prompt in frosted glass.
class NotificationsSettingsTile extends ConsumerWidget {
  const NotificationsSettingsTile({super.key});

  Future<void> _playAlertSound(AlertTone tone) async {
    // 1. Play real system alert sound
    await SystemSound.play(SystemSoundType.alert);

    // 2. Play tactile vibration tone according to selected tone
    switch (tone) {
      case AlertTone.cyberRadar:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.mediumImpact();
        break;
      case AlertTone.tacticalPulse:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        break;
      case AlertTone.enterprisePing:
        await HapticFeedback.lightImpact();
        break;
      case AlertTone.hapticOnly:
        await HapticFeedback.vibrate();
        break;
    }
  }

  void _triggerTestAlert(BuildContext context, AlertTone tone) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger audible tone and vibration
    unawaited(_playAlertSound(tone));

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
                      children: [
                        Expanded(
                          child: Text(
                            '🚨 CRITICAL CANARY ALERT',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: colors.critical,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
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

  void _requestSystemPermission(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notifications_active_rounded, color: colors.brandPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Allow Notifications?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'LeukQuant requires notification permission to alert you immediately when a decoy trap or canary credential is triggered by an attacker.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(notificationAccessProvider.notifier).togglePermission(false);
            },
            child: Text('Don\'t Allow', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.brandPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(notificationAccessProvider.notifier).togglePermission(true);
              _playAlertSound(AlertTone.enterprisePing);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Notification permission granted. Canary alerts are active.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Allow'),
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
    final hasNotificationAccess = ref.watch(notificationAccessProvider);
    final currentTone = ref.watch(alertToneProvider);

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications_active_outlined, size: 18, color: colors.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts & Notifications',
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
              color: colors.surfaceMuted.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
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
                        hasNotificationAccess ? 'Permission granted' : 'Tap switch to allow',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasNotificationAccess ? colors.success : colors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Ios26Switch(
                  value: hasNotificationAccess,
                  activeColor: colors.success,
                  onChanged: (val) {
                    if (val) {
                      _requestSystemPermission(context, ref);
                    } else {
                      ref.read(notificationAccessProvider.notifier).togglePermission(false);
                    }
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
                    ? colors.brandPrimary.withValues(alpha: isDark ? 0.14 : 0.08)
                    : colors.surfaceMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? colors.brandPrimary.withValues(alpha: 0.45)
                      : colors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: Colors.transparent,
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
                    trailing: IconButton(
                      icon: Icon(Icons.volume_up_rounded, size: 18, color: isSelected ? colors.brandPrimary : colors.textSecondary),
                      tooltip: 'Play sample sound',
                      onPressed: () => _playAlertSound(tone),
                    ),
                    onTap: () {
                      ref.read(alertToneProvider.notifier).setTone(tone);
                      _playAlertSound(tone);
                    },
                  ),
                ),
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
                'Test Alert Simulation (Audio + Banner)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
