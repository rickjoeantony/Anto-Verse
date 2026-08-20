import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:leukquant_mobile/core/constants/app_constants.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/theme/theme_controller.dart';
import 'package:leukquant_mobile/features/auth/presentation/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SplashScreen renders logo, subtitle, and loading indicator',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen Mock')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const Scaffold(body: Text('Onboarding Screen Mock')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );

    expect(find.text(AppConstants.appSubtitle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Initializing workspace...'), findsOneWidget);

    // Let the timer complete cleanly with GoRouter navigation
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  });
}
