// test/widget/responsive_screens_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/widgets/glass_bottom_nav.dart';
import 'package:leukquant_mobile/core/widgets/security_posture_hero.dart';
import 'package:leukquant_mobile/core/widgets/incident_timeline_stepper.dart';
import 'package:leukquant_mobile/features/incidents/domain/incident.dart';

void main() {
  group('Responsive Breakpoints & Zero Overflow Tests', () {
    const screenSizes = [
      Size(320, 568),  // Small Phone
      Size(375, 812),  // Standard Phone
      Size(768, 1024), // Tablet
      Size(844, 390),  // Landscape Phone
    ];

    for (final size in screenSizes) {
      testWidgets('Renders SecurityPostureHero without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: SecurityPostureHero(
                  isBackendConnected: false,
                  hasActiveIncident: false,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Ghost-Net Deployment'), findsOneWidget);
        expect(find.text('Awaiting Signals'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders GlassBottomNav without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              bottomNavigationBar: GlassBottomNav(
                currentIndex: selectedIndex,
                onItemSelected: (idx) => selectedIndex = idx,
                items: const [
                  GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
                  GlassNavItem(icon: Icons.stream_rounded, label: 'Events'),
                  GlassNavItem(icon: Icons.shield_rounded, label: 'Incidents'),
                  GlassNavItem(icon: Icons.more_horiz_rounded, label: 'More'),
                ],
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Events'), findsOneWidget);
        expect(find.text('Incidents'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders IncidentTimelineStepper without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: IncidentTimelineStepper(
                  status: 'Under Triage',
                  timeline: [
                    IncidentTimelineStage(
                      stage: 'Detection',
                      description: 'Canary token triggered.',
                      timestamp: '14:22 UTC',
                      isCompleted: true,
                    ),
                    IncidentTimelineStage(
                      stage: 'Review',
                      description: 'Analyst triage in progress.',
                      timestamp: '14:24 UTC',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Detect'), findsOneWidget); // compact label
        expect(tester.takeException(), isNull);
      });
    }
  });
}
