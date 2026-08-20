import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/widgets/severity_badge.dart';
import 'package:leukquant_mobile/features/events/domain/severity_level.dart';

void main() {
  testWidgets('SeverityBadge renders correct label and uppercase text in light theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SeverityBadge(severity: SeverityLevel.critical),
        ),
      ),
    );

    expect(find.text('CRITICAL'), findsOneWidget);
  });

  testWidgets('SeverityBadge renders in dark theme with custom label',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: SeverityBadge(
            severity: SeverityLevel.high,
            customLabel: 'Elevated Risk',
          ),
        ),
      ),
    );

    expect(find.text('ELEVATED RISK'), findsOneWidget);
  });
}
