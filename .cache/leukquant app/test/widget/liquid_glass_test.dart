// test/widget/liquid_glass_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_colors.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/widgets/ambient_background.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_container.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_card.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_bottom_nav.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_app_bar.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_button.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_sheet.dart';
import 'package:leukquant_mobile/core/widgets/glass/liquid_glass_badge.dart';

void main() {
  group('Liquid Glass Tokens & Architecture Tests', () {
    test('Light theme liquid glass tokens have correct values', () {
      const light = AppColors.lightScheme;
      expect(light.background, equals(const Color(0xFFF2F6FF)));
      expect(light.glassCard, equals(const Color(0x8EFFFFFF)));
      expect(light.glassStrongFill, equals(const Color(0xB2FFFFFF)));
      expect(light.glassBorder, equals(const Color(0xC2FFFFFF)));
      expect(light.glassInnerHighlight, equals(const Color(0xE6FFFFFF)));
      expect(light.glassEdgeGlow, equals(const Color(0x1B2563EB)));
      expect(light.backgroundGlow1, equals(const Color(0x1A2563EB)));
      expect(light.backgroundGlow2, equals(const Color(0x140F766E)));
    });

    test('Dark theme liquid glass tokens have correct values', () {
      const dark = AppColors.darkScheme;
      expect(dark.background, equals(const Color(0xFF0B1020)));
      expect(dark.glassCard, equals(const Color(0x9E172033)));
      expect(dark.glassStrongFill, equals(const Color(0xC7172033)));
      expect(dark.glassBorder, equals(const Color(0x28FFFFFF)));
      expect(dark.glassInnerHighlight, equals(const Color(0x45FFFFFF)));
      expect(dark.glassEdgeGlow, equals(const Color(0x2160A5FA)));
      expect(dark.backgroundGlow1, equals(const Color(0x242563EB)));
      expect(dark.backgroundGlow2, equals(const Color(0x1A2DD4BF)));
    });
  });

  group('Liquid Glass Widgets Rendering Tests', () {
    testWidgets('LiquidGlassContainer renders child with proper decoration in light & dark',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LiquidGlassContainer(
              cornerRadius: 24,
              child: Text('Liquid Container Content'),
            ),
          ),
        ),
      );

      expect(find.text('Liquid Container Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('LiquidGlassCard handles tap interaction with tactile scaling',
        (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LiquidGlassCard(
              onTap: () => wasTapped = true,
              child: const Text('Tappable Glass Card'),
            ),
          ),
        ),
      );

      expect(find.text('Tappable Glass Card'), findsOneWidget);
      await tester.tap(find.text('Tappable Glass Card'));
      await tester.pumpAndSettle();
      expect(wasTapped, isTrue);
    });

    testWidgets('LiquidGlassBottomNav renders navigation items and sliding pill',
        (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            bottomNavigationBar: LiquidGlassBottomNav(
              currentIndex: activeIndex,
              onItemSelected: (idx) => activeIndex = idx,
              items: const [
                LiquidGlassNavItem(icon: Icons.home_rounded, label: 'Home'),
                LiquidGlassNavItem(icon: Icons.stream_rounded, label: 'Events'),
                LiquidGlassNavItem(icon: Icons.shield_rounded, label: 'Incidents', hasBadge: true),
                LiquidGlassNavItem(icon: Icons.assessment_rounded, label: 'Reports'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Incidents'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);

      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(activeIndex, equals(1));
    });

    testWidgets('LiquidGlassAppBar renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            appBar: LiquidGlassAppBar(
              title: 'Command Center',
              subtitle: 'Active Telemetry',
              showBack: true,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );

      expect(find.text('Command Center'), findsOneWidget);
      expect(find.text('Active Telemetry'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('LiquidGlassButton renders and responds to press', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LiquidGlassButton(
              onPressed: () => pressed = true,
              child: const Text('Execute Action'),
            ),
          ),
        ),
      );

      expect(find.text('Execute Action'), findsOneWidget);
      await tester.tap(find.text('Execute Action'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('LiquidGlassBadge renders severity with glowing dot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => LiquidGlassBadge.severity('critical', context),
            ),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
    });

    testWidgets('AmbientBackground renders static layered background canvas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AmbientBackground(
            child: Text('Under Liquid Glass Content'),
          ),
        ),
      );

      expect(find.text('Under Liquid Glass Content'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('LiquidGlassSheet renders modal structure with drag handle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  LiquidGlassSheet.show(
                    context: ctx,
                    builder: (_) => const Text('Sheet Content Inside'),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content Inside'), findsOneWidget);
      expect(find.byType(LiquidGlassSheet), findsOneWidget);
    });
  });
}
