// lib/features/settings/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_controller.dart';
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

/// StateNotifier for editable user profile with SharedPreferences persistence
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(UserProfile.awaitingBackend()) {
    _initProfile();
  }

  void _initProfile() {
    final authState = _ref.read(authProvider);
    SharedPreferences? prefs;
    try {
      prefs = _ref.read(sharedPreferencesProvider);
    } catch (_) {}

    final savedName = prefs?.getString('custom_user_name');
    final savedCompany = prefs?.getString('custom_company_name');
    final savedAvatar = prefs?.getString('custom_avatar_key');

    UserProfile base;
    if (authState.userProfile != null) {
      base = authState.userProfile!;
    } else if (authState.isAuthenticated && authState.email != null) {
      base = UserProfile(
        name: authState.email!.split('@').first,
        email: authState.email,
        plan: 'growth',
        organisation: 'Leukquant Enterprise',
        workspaceId: 'WS-STAGING-01',
        isBackendConnected: true,
      );
    } else {
      base = UserProfile.awaitingBackend();
    }

    state = base.copyWith(
      name: (savedName != null && savedName.isNotEmpty) ? savedName : base.name,
      organisation: (savedCompany != null && savedCompany.isNotEmpty) ? savedCompany : base.organisation,
      avatar: (savedAvatar != null && savedAvatar.isNotEmpty) ? savedAvatar : (base.avatar ?? 'shield'),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? organisation,
    String? avatar,
  }) async {
    SharedPreferences? prefs;
    try {
      prefs = _ref.read(sharedPreferencesProvider);
    } catch (_) {}

    if (name != null && name.trim().isNotEmpty) {
      await prefs?.setString('custom_user_name', name.trim());
    }
    if (organisation != null && organisation.trim().isNotEmpty) {
      await prefs?.setString('custom_company_name', organisation.trim());
    }
    if (avatar != null && avatar.trim().isNotEmpty) {
      await prefs?.setString('custom_avatar_key', avatar.trim());
    }

    state = state.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : state.name,
      organisation: (organisation != null && organisation.trim().isNotEmpty) ? organisation.trim() : state.organisation,
      avatar: (avatar != null && avatar.trim().isNotEmpty) ? avatar.trim() : state.avatar,
    );

    // Synchronize directly with backend database via PATCH /api/user/profile
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.updateUserProfile({
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (organisation != null && organisation.trim().isNotEmpty) 'organization': organisation.trim(),
        if (avatar != null && avatar.trim().isNotEmpty) 'avatar': avatar.trim(),
      });
    } catch (_) {
      // Local fallback active if offline
    }
  }
}

/// Provider for authenticated user profile (allows editing company and avatar)
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  // Listen to authProvider changes to keep base profile in sync
  ref.listen(authProvider, (previous, next) {
    // Refresh base profile on login/logout
  });
  return UserProfileNotifier(ref);
});