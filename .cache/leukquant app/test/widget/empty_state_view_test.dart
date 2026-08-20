import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/theme/app_theme.dart';
import 'package:leukquant_mobile/core/widgets/empty_state_view.dart';

void main() {
  testWidgets('EmptyStateView renders icon, title, description, and action button',
      (WidgetTester tester) async {
    bool actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.inbox_outlined,
            title: 'No Items Available',
            description: 'This is a calm empty state description.',
            actionLabel: 'Refresh Feed',
            onAction: () {
              actionPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('No Items Available'), findsOneWidget);
    expect(find.text('This is a calm empty state description.'), findsOneWidget);
    expect(find.text('Refresh Feed'), findsOneWidget);

    await tester.tap(find.text('Refresh Feed'));
    expect(actionPressed, isTrue);
  });
}
