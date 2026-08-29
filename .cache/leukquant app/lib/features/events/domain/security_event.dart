// lib/features/events/domain/security_event.dart

import 'severity_level.dart';

/// Clean domain model representing a captured credential pair with strictly masked password.
class CredentialItem {
  final String username;
  final String maskedPassword;

  const CredentialItem({
    required this.username,
    this.maskedPassword = '••••••••',
  });

  /// Parse from JSON while immediately discarding raw password and enforcing bullet masking.
  factory CredentialItem.fromJson(Map<String, dynamic> json) {
    final user = (json['username'] ?? json['user'] ?? json['account'] ?? 'root').toString();
    return CredentialItem(
      username: user,
      maskedPassword: '••••••••',
    );
  }

  @override
  String toString() => '$username ••••••••';
}

/// Clean domain model representing a verified security telemetry event from middle-man-3.
class SecurityEvent {
  final String id;
  final DateTime timestamp;
  final String sourceIp;
  final String country;
  final String countryCode;
  final double? lat;
  final double? lng;
  final String type;
  final int threatLevel; // 1 to 5
  final String honeypot;
  final String payload; // Sanitized, truncated safe preview
  final double abuseScore;
  final bool reviewed;
  final List<CredentialItem> credentials;

  // Compatibility / SOC analysis fields
  final String protocol;
  final String destinationPort;
  final String canaryReference;
  final String recommendedAction;
  final List<String> classificationReasons;

  const SecurityEvent({
    required this.id,
    required this.timestamp,
    required this.sourceIp,
    required this.country,
    required this.countryCode,
    this.lat,
    this.lng,
    required this.type,
    required this.threatLevel,
    required this.honeypot,
    required this.payload,
    required this.abuseScore,
    required this.reviewed,
    required this.credentials,
    required this.protocol,
    required this.destinationPort,
    required this.canaryReference,
    required this.recommendedAction,
    required this.classificationReasons,
  });

  /// Classification alias for UI components
  String get classification => type;

  /// Severity derived from threatLevel (1-5) or fallback string
  SeverityLevel get severity {
    switch (threatLevel) {
      case 5:
        return SeverityLevel.critical;
      case 4:
        return SeverityLevel.high;
      case 3:
        return SeverityLevel.warning;
      case 2:
        return SeverityLevel.low;
      case 1:
      default:
        return SeverityLevel.info;
    }
  }

  /// Formatted credential string for UI: "root ••••••••"
  String get maskedCredentials {
    if (credentials.isNotEmpty) {
      return credentials.map((c) => '${c.username} ••••••••').join(', ');
    }
    return 'root ••••••••';
  }

  /// Sanitize and truncate raw payload (80–120 chars, control characters removed, no execution).
  static String sanitizePayload(dynamic raw) {
    if (raw == null) return '—';
    String str = raw.toString();
    // Strip control characters (ASCII 0-31 except space, and 127)
    str = str.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    if (str.length > 100) {
      str = '${str.substring(0, 97)}...';
    }
    return str.isEmpty ? '—' : str;
  }

  /// Parse from real middle-man-3 staging API JSON response.
  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    // 1. ID
    final id = (json['id'] ?? json['event_id'] ?? json['external_event_id'] ?? 'EVT-UNKNOWN').toString();

    // 2. Timestamp
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

    // 3. IPs & Geo
    final sourceIp = (json['sourceIP'] ?? json['source_ip'] ?? json['attacker_ip'] ?? json['src_ip'] ?? '0.0.0.0').toString();
    final country = (json['country'] ?? 'Unknown Location').toString();
    final countryCode = (json['countryCode'] ?? json['country_code'] ?? 'UN').toString();
    final lat = (json['lat'] is num) ? (json['lat'] as num).toDouble() : null;
    final lng = (json['lng'] is num) ? (json['lng'] as num).toDouble() : null;

    // 4. Type / AttackType / Classification
    final type = (json['type'] ??
            json['attackType'] ??
            json['attack_type'] ??
            json['classification'] ??
            json['threat_type'] ??
            'Unclassified Telemetry Probe')
        .toString();

    // 5. ThreatLevel (1 to 5)
    int threatLevel = 1;
    if (json['threatLevel'] is num) {
      threatLevel = (json['threatLevel'] as num).toInt().clamp(1, 5);
    } else if (json['threat_level'] is num) {
      threatLevel = (json['threat_level'] as num).toInt().clamp(1, 5);
    } else if (json['severity'] != null) {
      final sev = SeverityLevel.fromString(json['severity'].toString());
      threatLevel = switch (sev) {
        SeverityLevel.critical => 5,
        SeverityLevel.high => 4,
        SeverityLevel.warning => 3,
        SeverityLevel.low => 2,
        _ => 1,
      };
    }

    // 6. Honeypot name
    final honeypot = (json['honeypot'] ??
            json['honeypotName'] ??
            json['honeypot_name'] ??
            json['canary_reference'] ??
            json['sensor_id'] ??
            'decoy-sensor-01')
        .toString();

    // 7. Sanitized safe payload preview
    final rawPayload = json['payload'] ?? json['command'] ?? json['data'];
    final payload = sanitizePayload(rawPayload);

    // 8. Abuse Score
    double abuseScore = 0.0;
    if (json['abuseScore'] is num) {
      abuseScore = (json['abuseScore'] as num).toDouble();
    } else if (json['abuse_score'] is num) {
      abuseScore = (json['abuse_score'] as num).toDouble();
    }

    // 9. Reviewed
    final bool reviewed = json['reviewed'] == true || json['is_reviewed'] == true;

    // 10. Credentials (Masked)
    final List<CredentialItem> credentialsList = [];
    if (json['credentials'] is List) {
      for (final item in json['credentials'] as List) {
        if (item is Map<String, dynamic>) {
          credentialsList.add(CredentialItem.fromJson(item));
        } else if (item != null) {
          credentialsList.add(CredentialItem(username: item.toString()));
        }
      }
    } else if (json['username'] != null || json['user'] != null) {
      final u = (json['username'] ?? json['user']).toString();
      credentialsList.add(CredentialItem(username: u));
    }

    // 11. Protocol & Target Port
    final protocol = (json['protocol'] ?? json['service'] ?? 'TCP').toString().toUpperCase();
    final destinationPort = (json['destination_port'] ??
            json['destinationPort'] ??
            json['target_port'] ??
            json['honeypot_port'] ??
            json['port'] ??
            '—')
        .toString();

    // 12. Classification Reasons
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
      reasons.add('Automated decoy interaction intercepted by Ghost-Net sensor.');
    }

    final action = (json['recommended_action'] ??
            json['recommendedAction'] ??
            json['action'] ??
            'Perimeter drop rule active on ingress firewall.')
        .toString();

    return SecurityEvent(
      id: id,
      timestamp: parsedTime,
      sourceIp: sourceIp,
      country: country,
      countryCode: countryCode,
      lat: lat,
      lng: lng,
      type: type,
      threatLevel: threatLevel,
      honeypot: honeypot,
      payload: payload,
      abuseScore: abuseScore,
      reviewed: reviewed,
      credentials: credentialsList,
      protocol: protocol,
      destinationPort: destinationPort,
      canaryReference: honeypot,
      recommendedAction: action,
      classificationReasons: reasons,
    );
  }

  /// Create a copy with updated properties (e.g. reviewed status).
  SecurityEvent copyWith({
    bool? reviewed,
    int? threatLevel,
    String? recommendedAction,
  }) {
    return SecurityEvent(
      id: id,
      timestamp: timestamp,
      sourceIp: sourceIp,
      country: country,
      countryCode: countryCode,
      lat: lat,
      lng: lng,
      type: type,
      threatLevel: threatLevel ?? this.threatLevel,
      honeypot: honeypot,
      payload: payload,
      abuseScore: abuseScore,
      reviewed: reviewed ?? this.reviewed,
      credentials: credentials,
      protocol: protocol,
      destinationPort: destinationPort,
      canaryReference: canaryReference,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      classificationReasons: classificationReasons,
    );
  }
}
