import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/features/events/domain/severity_level.dart';

void main() {
  group('SeverityLevel Unit Tests', () {
    test('Correctly parses strings into SeverityLevel enum', () {
      expect(SeverityLevel.fromString('critical'), equals(SeverityLevel.critical));
      expect(SeverityLevel.fromString('HIGH'), equals(SeverityLevel.high));
      expect(SeverityLevel.fromString('warning'), equals(SeverityLevel.warning));
      expect(SeverityLevel.fromString('warn'), equals(SeverityLevel.warning));
      expect(SeverityLevel.fromString('info'), equals(SeverityLevel.info));
      expect(SeverityLevel.fromString('low'), equals(SeverityLevel.low));
      expect(SeverityLevel.fromString('healthy'), equals(SeverityLevel.healthy));
      expect(SeverityLevel.fromString('success'), equals(SeverityLevel.success));
      expect(SeverityLevel.fromString('unknown_value'), equals(SeverityLevel.info));
    });

    test('Provides valid display names', () {
      expect(SeverityLevel.critical.displayName, equals('Critical'));
      expect(SeverityLevel.high.displayName, equals('High'));
      expect(SeverityLevel.warning.displayName, equals('Warning'));
      expect(SeverityLevel.info.displayName, equals('Info'));
      expect(SeverityLevel.healthy.displayName, equals('Healthy'));
    });
  });
}
