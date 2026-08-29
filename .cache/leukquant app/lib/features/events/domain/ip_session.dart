// lib/features/events/domain/ip_session.dart

import 'security_event.dart';

/// Single captured session for an attacker IP
class CapturedSession {
  final String sessionId;
  final DateTime timestamp;
  final String protocol;
  final String honeypot;
  final List<String> commands; // Read-only commands
  final List<CredentialItem> credentials; // Strictly masked passwords only

  const CapturedSession({
    required this.sessionId,
    required this.timestamp,
    required this.protocol,
    required this.honeypot,
    required this.commands,
    required this.credentials,
  });

  factory CapturedSession.fromJson(Map<String, dynamic> json) {
    final id = (json['sessionId'] ?? json['session_id'] ?? json['id'] ?? 'SESS-UNKNOWN').toString();

    DateTime time;
    try {
      final rawTime = json['timestamp'] ?? json['started_at'] ?? json['created_at'];
      if (rawTime is String) {
        time = DateTime.parse(rawTime);
      } else if (rawTime is int) {
        time = DateTime.fromMillisecondsSinceEpoch(rawTime);
      } else {
        time = DateTime.now();
      }
    } catch (_) {
      time = DateTime.now();
    }

    final proto = (json['protocol'] ?? json['service'] ?? 'SSH').toString().toUpperCase();
    final honeypot = (json['honeypot'] ?? json['honeypot_name'] ?? 'decoy-01').toString();

    final List<String> cmdList = [];
    if (json['commands'] is List) {
      for (final cmd in json['commands'] as List) {
        if (cmd != null) {
          cmdList.add(SecurityEvent.sanitizePayload(cmd.toString()));
        }
      }
    } else if (json['payload'] != null) {
      cmdList.add(SecurityEvent.sanitizePayload(json['payload'].toString()));
    }

    final List<CredentialItem> credsList = [];
    if (json['credentials'] is List) {
      for (final cred in json['credentials'] as List) {
        if (cred is Map<String, dynamic>) {
          credsList.add(CredentialItem.fromJson(cred));
        } else if (cred != null) {
          credsList.add(CredentialItem(username: cred.toString()));
        }
      }
    }

    return CapturedSession(
      sessionId: id,
      timestamp: time,
      protocol: proto,
      honeypot: honeypot,
      commands: cmdList,
      credentials: credsList,
    );
  }
}

/// IP Sessions telemetry container
class IpSessionsData {
  final String ip;
  final int totalSessions;
  final List<CapturedSession> sessions;

  const IpSessionsData({
    required this.ip,
    required this.totalSessions,
    required this.sessions,
  });

  factory IpSessionsData.fromJson(String ip, dynamic data) {
    final List<CapturedSession> list = [];
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(CapturedSession.fromJson(item));
        }
      }
    } else if (data is Map<String, dynamic>) {
      if (data['sessions'] is List) {
        for (final item in data['sessions'] as List) {
          if (item is Map<String, dynamic>) {
            list.add(CapturedSession.fromJson(item));
          }
        }
      }
    }

    return IpSessionsData(
      ip: ip,
      totalSessions: list.length,
      sessions: list,
    );
  }
}
