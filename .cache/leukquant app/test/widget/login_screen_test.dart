import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/theme/theme_controller.dart';
import 'package:leukquant_mobile/features/auth/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LoginScreen renders welcome header, inputs, and sign in button',
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
          home: const LoginScreen(),
        ),
      ),
    );

    // Pump a single frame duration to allow entrance animations without blocking on continuous loops
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Sign in to access your organisation’s security workspace.'),
      findsOneWidget,
    );
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
