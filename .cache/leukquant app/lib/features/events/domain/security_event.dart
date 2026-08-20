// lib/features/events/domain/security_event.dart

import 'severity_level.dart';

/// Clean domain model representing a verified security telemetry event.
class SecurityEvent {
  final String id;
  final String classification;
  final List<String> classificationReasons;
  final SeverityLevel severity;
  final String protocol;
  final String sourceIp;
  final String country;
  final String canaryReference;
  final String recommendedAction;
  final String maskedCredentials;
  final DateTime timestamp;
  final String destinationPort;

  const SecurityEvent({
    required this.id,
    required this.classification,
    required this.classificationReasons,
    required this.severity,
    required this.protocol,
    required this.sourceIp,
    required this.country,
    required this.canaryReference,
    required this.recommendedAction,
    required this.maskedCredentials,
    required this.timestamp,
    required this.destinationPort,
  });

  /// Parse from real middle-man-3 staging API JSON response.
  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    // 1. Safe ID extraction
    final id = (json['id'] ?? json['event_id'] ?? json['external_event_id'] ?? 'EVT-UNKNOWN').toString();

    // 2. Classification
    final classification = (json['classification'] ??
            json['threat_type'] ??
            json['title'] ??
            'Unclassified Telemetry Probe')
        .toString();

    // 3. Reasons list
    final List<String> reasons = [];
    if (json['classification_reasons'] is List) {
      for (final r in json['classification_reasons'] as List) {
        if (r != null) reasons.add(r.toString());
      }
    } else if (json['reasons'] is List) {
      for (final r in json['reasons'] as List) {
        if (r != null) reasons.add(r.toString());
      }
    } else if (json['reason'] != null) {
      reasons.add(json['reason'].toString());
    } else if (json['description'] != null) {
      reasons.add(json['description'].toString());
    }

    if (reasons.isEmpty) {
      reasons.add('Automated decoy threshold interaction detected.');
    }

    // 4. Severity
    final rawSeverity = (json['severity'] ?? json['severity_level'] ?? 'info').toString().toLowerCase();
    final severity = SeverityLevel.fromString(rawSeverity);

    // 5. Protocol & IPs
    final protocol = (json['protocol'] ?? json['service'] ?? 'TCP').toString().toUpperCase();
    final sourceIp = (json['source_ip'] ?? json['attacker_ip'] ?? json['src_ip'] ?? '0.0.0.0').toString();
    final country = (json['country'] ?? json['country_code'] ?? json['geo'] ?? 'Unknown Location').toString();
    final canaryRef = (json['canary_reference'] ?? json['canary_id'] ?? json['sensor_id'] ?? json['decoy_name'] ?? 'canary-sensor-edge').toString();
    final action = (json['recommended_action'] ?? json['action'] ?? 'Maintain perimeter drop rule on ingress firewall.').toString();

    // 6. Target / Honeypot port (NEVER source port)
    final port = (json['target_port'] ??
            json['honeypot_port'] ??
            json['decoy_port'] ??
            json['destination_port'] ??
            json['dst_port'] ??
            json['port'] ??
            '—')
        .toString();

    // 7. Strict credential masking by design
    final maskedCreds = _sanitizeCredentials(json);

    // 8. Timestamp
    DateTime parsedTime;
    try {
      final rawTime = json['timestamp'] ?? json['created_at'] ?? json['time'];
      if (rawTime is String) {
        parsedTime = DateTime.parse(rawTime);
      } else if (rawTime is int) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
      } else {
        parsedTime = DateTime.now();
      }
    } catch (_) {
      parsedTime = DateTime.now();
    }

    return SecurityEvent(
      id: id,
      classification: classification,
      classificationReasons: reasons,
      severity: severity,
      protocol: protocol,
      sourceIp: sourceIp,
      country: country,
      canaryReference: canaryRef,
      recommendedAction: action,
      maskedCredentials: maskedCreds,
      timestamp: parsedTime,
      destinationPort: port,
    );
  }

  /// Ensure credentials are NEVER shown in raw text (always strictly masked).
  static String _sanitizeCredentials(Map<String, dynamic> json) {
    if (json.containsKey('masked_credentials') && json['masked_credentials'] != null) {
      return json['masked_credentials'].toString();
    }
    final user = json['username'] ?? json['user'] ?? json['account'] ?? 'admin';
    return '$user / **********';
  }
}
