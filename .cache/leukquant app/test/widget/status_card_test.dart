import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/widgets/status_card.dart';

void main() {
  testWidgets('StatusCard renders title, child, and trailing widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StatusCard(
            title: 'Deployment Health',
            trailing: Text('TRAILING'),
            child: Text('Card Content Body'),
          ),
        ),
      ),
    );

    expect(find.text('Deployment Health'), findsOneWidget);
    expect(find.text('TRAILING'), findsOneWidget);
    expect(find.text('Card Content Body'), findsOneWidget);
  });
}
