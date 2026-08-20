import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/constants/app_constants.dart';
import 'package:leukquant_mobile/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier Unit Tests', () {
    test('Initializes with system theme when no preference is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, equals(ThemeMode.system));
    });

    test('Initializes with dark theme when stored preference is dark', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.themeModeKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, equals(ThemeMode.dark));
    });

    test('Updates theme mode and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));
      expect(prefs.getString(AppConstants.themeModeKey), equals('light'));

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(prefs.getString(AppConstants.themeModeKey), equals('dark'));
    });

    test('Toggles theme between dark and light', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.dark));

      notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.light));
    });
  });

  group('InAppAlertsNotifier Unit Tests', () {
    test('Defaults to true when no preference exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = InAppAlertsNotifier(prefs);

      expect(notifier.state, isTrue);
    });

    test('Updates alert preference and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = InAppAlertsNotifier(prefs);

      await notifier.setInAppAlerts(false);
      expect(notifier.state, isFalse);
      expect(prefs.getBool(AppConstants.inAppAlertsKey), isFalse);
    });
  });
}
