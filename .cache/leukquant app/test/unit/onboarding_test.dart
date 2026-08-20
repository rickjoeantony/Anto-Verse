import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/constants/app_constants.dart';
import 'package:leukquant_mobile/features/onboarding/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingProvider Unit Tests', () {
    test('Defaults to false when onboarding has not been completed', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = OnboardingNotifier(prefs);

      expect(notifier.state, isFalse);
    });

    test('Completes onboarding and saves flag to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = OnboardingNotifier(prefs);

      await notifier.completeOnboarding();
      expect(notifier.state, isTrue);
      expect(prefs.getBool(AppConstants.onboardingCompletedKey), isTrue);
    });

    test('Resets onboarding state', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.onboardingCompletedKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = OnboardingNotifier(prefs);

      expect(notifier.state, isTrue);
      await notifier.resetOnboarding();
      expect(notifier.state, isFalse);
      expect(prefs.getBool(AppConstants.onboardingCompletedKey), isNull);
    });
  });
}
