// lib/features/settings/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../domain/user_profile.dart';

/// Available alert tones for security telemetry events
enum AlertTone {
  cyberRadar('Cyber Radar', 'High priority frequency pulse for decoy triggers'),
  tacticalPulse('Tactical Pulse', 'Low resonance alert for canary token access'),
  enterprisePing('Enterprise Ping', 'Clean discrete notification sound'),
  hapticOnly('Haptic Only', 'Silent physical vibration feedback');

  final String title;
  final String description;
  const AlertTone(this.title, this.description);
}

/// State notifier for user-selected alert tone
class AlertToneNotifier extends StateNotifier<AlertTone> {
  AlertToneNotifier() : super(AlertTone.cyberRadar);

  void setTone(AlertTone tone) {
    state = tone;
  }
}

final alertToneProvider = StateNotifierProvider<AlertToneNotifier, AlertTone>((ref) {
  return AlertToneNotifier();
});

/// State notifier for notification access permission
class NotificationAccessNotifier extends StateNotifier<bool> {
  NotificationAccessNotifier() : super(true);

  void togglePermission(bool enabled) {
    state = enabled;
  }
}

final notificationAccessProvider = StateNotifierProvider<NotificationAccessNotifier, bool>((ref) {
  return NotificationAccessNotifier();
});

/// Provider for authenticated user profile.
final userProfileProvider = Provider<UserProfile>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.userProfile != null) {
    return authState.userProfile!;
  }
  if (authState.isAuthenticated && authState.email != null) {
    return UserProfile(
      name: authState.email!.split('@').first,
      email: authState.email,
      role: 'SOC Analyst',
      organisation: 'Enterprise Workspace',
      workspaceId: 'WS-STAGING-01',
      isBackendConnected: true,
    );
  }
  return UserProfile.awaitingBackend();
});
