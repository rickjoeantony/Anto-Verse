import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/features/events/domain/security_event.dart';
import 'package:leukquant_mobile/features/events/domain/severity_level.dart';

void main() {
  group('SecurityEvent JSON Parsing and Filtering Tests', () {
    final sampleJsonList = [
      {
        'id': 'EVT-2026-8941',
        'classification': 'Automated SSH Credential Spray',
        'classification_reasons': ['14 consecutive authentication failures in 30s window'],
        'severity': 'critical',
        'protocol': 'SSH',
        'source_ip': '198.51.100.44',
        'country': 'Germany (DE)',
        'canary_reference': 'canary-ssh-edge-02',
        'target_port': '2222',
        'username': 'admin',
      },
      {
        'id': 'EVT-2026-8938',
        'classification': 'Suspicious TLS Handshake Anomaly',
        'reasons': ['Obsolete cipher suite negotiation attempted'],
        'severity': 'high',
        'protocol': 'HTTPS',
        'source_ip': '203.0.113.89',
        'country': 'Singapore (SG)',
        'canary_reference': 'canary-web-dmz-01',
        'target_port': '443',
        'username': 'api_user',
      },
      {
        'id': 'EVT-2026-8920',
        'classification': 'Decoy Database Query Probe',
        'severity': 'warning',
        'protocol': 'PostgreSQL',
        'source_ip': '192.0.2.112',
        'country': 'United States (US)',
        'canary_reference': 'canary-db-prod-01',
        'target_port': '5432',
      },
    ];

    late List<SecurityEvent> events;

    setUp(() {
      events = sampleJsonList.map((j) => SecurityEvent.fromJson(j)).toList();
    });

    test('Parsed events have masked credentials only', () {
      for (final event in events) {
        expect(
          event.maskedCredentials.contains('***') ||
              event.maskedCredentials.startsWith('N/A'),
          isTrue,
          reason: 'Event ${event.id} credentials must be masked',
        );
      }
    });

    test('Target port is properly extracted without using source port', () {
      expect(events[0].destinationPort, equals('2222'));
      expect(events[1].destinationPort, equals('443'));
      expect(events[2].destinationPort, equals('5432'));
    });

    test('Filters events by severity level', () {
      final criticalEvents =
          events.where((e) => e.severity == SeverityLevel.critical).toList();
      expect(criticalEvents.length, equals(1));
      expect(criticalEvents.first.id, equals('EVT-2026-8941'));
    });

    test('Filters events by protocol', () {
      final sshEvents =
          events.where((e) => e.protocol.toUpperCase() == 'SSH').toList();
      expect(sshEvents.length, equals(1));
      expect(sshEvents.first.protocol, equals('SSH'));
    });

    test('Filters events by search query matching IP or ID', () {
      const query = 'EVT-2026-8941';
      final matched = events
          .where((e) => e.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(matched.length, equals(1));
      expect(matched.first.id, equals('EVT-2026-8941'));
    });
  });
}
