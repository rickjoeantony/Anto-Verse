import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_controller.dart';

/// Notifier managing onboarding completion state.
class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool(AppConstants.onboardingCompletedKey) ?? false);

  Future<void> completeOnboarding() async {
    state = true;
    await _prefs.setBool(AppConstants.onboardingCompletedKey, true);
  }

  Future<void> resetOnboarding() async {
    state = false;
    await _prefs.remove(AppConstants.onboardingCompletedKey);
  }
}

/// Global provider for onboarding completion state.
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});
