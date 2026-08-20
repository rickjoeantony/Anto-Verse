import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/theme/theme_controller.dart';
import 'package:leukquant_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OnboardingScreen renders initial onboarding step with brand title and skip button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('See suspicious activity early'), findsOneWidget);
    expect(find.text('OBSERVE'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });
}
