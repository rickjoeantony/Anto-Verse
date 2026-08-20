// lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Provider for shared_preferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main()');
});

/// Riverpod notifier managing ThemeMode (System, Light, Dark).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadInitialTheme(_prefs));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.themeModeKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.themeModeKey, value);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

/// Global provider for application ThemeMode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// Riverpod notifier managing in-app alerts preference.
class InAppAlertsNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  InAppAlertsNotifier(this._prefs)
      : super(_prefs.getBool(AppConstants.inAppAlertsKey) ?? true);

  Future<void> setInAppAlerts(bool enabled) async {
    state = enabled;
    await _prefs.setBool(AppConstants.inAppAlertsKey, enabled);
  }
}

/// Global provider for in-app alert preference.
final inAppAlertsProvider = StateNotifierProvider<InAppAlertsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return InAppAlertsNotifier(prefs);
});
