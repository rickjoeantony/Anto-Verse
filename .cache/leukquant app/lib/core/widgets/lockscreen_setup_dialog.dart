// lib/core/widgets/lockscreen_setup_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import 'glass/liquid_glass_button.dart';
import 'glass/liquid_glass_card.dart';

/// Modal dialog ensuring all Android lock-screen and background notification permissions are configured.
class LockScreenSetupDialog extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const LockScreenSetupDialog({
    super.key,
    this.onComplete,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LockScreenSetupDialog(onComplete: onComplete),
    );
  }

  @override
  ConsumerState<LockScreenSetupDialog> createState() => _LockScreenSetupDialogState();
}

class _LockScreenSetupDialogState extends ConsumerState<LockScreenSetupDialog> with WidgetsBindingObserver {
  bool _isBatteryUnrestricted = false;
  bool _isTestingAlert = false;
  int _testCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    final unrestricted = await NotificationService.instance.isBatteryOptimizationIgnored();
    if (mounted) {
      setState(() {
        _isBatteryUnrestricted = unrestricted;
      });
    }
  }

  void _startLockScreenTest() {
    setState(() {
      _isTestingAlert = true;
      _testCountdown = 4;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_testCountdown <= 1) {
        timer.cancel();
        setState(() {
          _isTestingAlert = false;
          _testCountdown = 0;
        });
        // Dispatch test alert with wake lock and loud alarm
        NotificationService.instance.sendTestNotification('cyberRadar');
      } else {
        setState(() {
          _testCountdown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: colors.brandPrimary.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      color: colors.brandPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lock-Screen Alert Setup',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Required for critical attack alarms when locked',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Step 1: Notifications & Sound
              _buildStepCard(
                context,
                stepNum: '1',
                title: 'Allow System Notifications',
                subtitle: 'Ensure lock-screen alerts & sound are turned on',
                icon: Icons.notifications_active_rounded,
                buttonText: 'Open Notifications',
                onTap: () => NotificationService.instance.openNotificationSettings(),
              ),
              const SizedBox(height: 12),

              // Step 2: Lock-Screen & Full-Screen Popups
              _buildStepCard(
                context,
                stepNum: '2',
                title: 'Full-Screen & Lock-Screen Pop-ups',
                subtitle: 'Allows critical attacks to pop up over your lock screen',
                icon: Icons.screen_lock_portrait_rounded,
                buttonText: 'Enable Lock-Screen Pop-up',
                onTap: () => NotificationService.instance.openFullScreenSettings(),
              ),
              const SizedBox(height: 12),

              // Step 3: Unrestricted Battery
              _buildStepCard(
                context,
                stepNum: '3',
                title: 'Set Battery to Unrestricted',
                subtitle: _isBatteryUnrestricted
                    ? '✓ Configured: App will not be killed in background'
                    : 'Prevents Android from putting live telemetry to sleep',
                icon: Icons.battery_charging_full_rounded,
                buttonText: _isBatteryUnrestricted ? '✓ Configured' : 'Set Unrestricted',
                isCompleted: _isBatteryUnrestricted,
                onTap: () => NotificationService.instance.openBatterySettings(),
              ),
              const SizedBox(height: 20),

              // Live Lock-Screen Tester Card
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.radar_rounded,
                          color: colors.brandPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Test Lock-Screen Wake Alarm',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isTestingAlert
                          ? '🔒 LOCK YOUR PHONE NOW! Alarm will trigger in $_testCountdown s...'
                          : 'Tap test, then lock your phone immediately to verify screen wake-up & loud chime.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _isTestingAlert ? colors.critical : colors.textSecondary,
                        fontWeight: _isTestingAlert ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: LiquidGlassButton(
                        onPressed: _isTestingAlert ? null : _startLockScreenTest,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isTestingAlert ? Icons.timer_rounded : Icons.play_arrow_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isTestingAlert
                                  ? 'Triggering in $_testCountdown s...'
                                  : '⚡ Test Alarm Now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Done / Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onComplete?.call();
                  },
                  child: const Text(
                    'I Have Completed Setup → Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNum,
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    bool isCompleted = false,
  }) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.success.withValues(alpha: 0.08)
            : colors.surfaceMuted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? colors.success.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colors.success.withOpacity(0.2)
                  : colors.brandPrimary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: colors.success, size: 18)
                  : Text(
                      stepNum,
                      style: TextStyle(
                        color: colors.brandPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCompleted ? colors.success : colors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(
                color: isCompleted ? colors.success : colors.brandPrimary,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            child: Text(
              buttonText,
              style: TextStyle(
                color: isCompleted ? colors.success : colors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
