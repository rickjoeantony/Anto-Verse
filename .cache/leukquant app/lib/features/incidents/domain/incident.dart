// lib/features/incidents/domain/incident.dart

import '../../events/domain/severity_level.dart';

/// Clean domain model for verified security incidents.
class Incident {
  final String id;
  final String title;
  final String description;
  final SeverityLevel severity;
  final String status;
  final String assignee;
  final String scope;
  final String recommendedAction;
  final DateTime createdAt;
  final String sourceIp;
  final String country;
  final String targetPort;
  final String protocol;
  final String payload;
  final bool isBlocked;
  final double abuseScore;
  final List<IncidentTimelineStage> timeline;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.assignee,
    required this.scope,
    required this.recommendedAction,
    required this.createdAt,
    this.sourceIp = '—',
    this.country = 'Global',
    this.targetPort = '—',
    this.protocol = 'TCP',
    this.payload = '—',
    this.isBlocked = false,
    this.abuseScore = 0.0,
    required this.timeline,
  });

  /// Parse from real API JSON response
  factory Incident.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['incident_id'] ?? 'INC-UNKNOWN').toString();
    final title = (json['title'] ?? 'Security Incident').toString();
    final desc = (json['description'] ?? 'Verified telemetry incident under active review.').toString();
    final rawSeverity = (json['severity'] ?? 'high').toString();
    final status = (json['status'] ?? 'Under Triage').toString();
    final assignee = (json['assignee'] ?? 'Security Operations Tier 2').toString();
    final scope = (json['scope'] ?? 'Honeynet Segment').toString();
    final action = (json['recommended_action'] ?? 'Review decoy sensor logs and apply ingress drop rules.').toString();
    final sourceIp = (json['source_ip'] ?? json['sourceIP'] ?? json['src_ip'] ?? '—').toString();
    final country = (json['country'] ?? 'Global').toString();
    final targetPort = (json['target_port'] ?? json['destination_port'] ?? json['port'] ?? '—').toString();
    final protocol = (json['protocol'] ?? 'TCP').toString().toUpperCase();
    final payload = (json['payload'] ?? json['command'] ?? '—').toString();
    final bool isBlocked = json['is_blocked'] == true || json['blocked'] == true;
    final double abuseScore = (json['abuse_score'] is num) ? (json['abuse_score'] as num).toDouble() : 0.0;

    DateTime time;
    try {
      final rawTime = json['created_at'] ?? json['timestamp'];
      time = rawTime is String ? DateTime.parse(rawTime) : DateTime.now();
    } catch (_) {
      time = DateTime.now();
    }

    final List<IncidentTimelineStage> stages = [];
    if (json['timeline'] is List) {
      for (final s in json['timeline'] as List) {
        if (s is Map<String, dynamic>) {
          stages.add(IncidentTimelineStage.fromJson(s));
        }
      }
    }

    if (stages.isEmpty) {
      stages.add(const IncidentTimelineStage(
        stage: 'Detection',
        description: 'Incident initiated via automated sensor threshold.',
        timestamp: 'Active',
        isCompleted: true,
      ));
    }

    return Incident(
      id: id,
      title: title,
      description: desc,
      severity: SeverityLevel.fromString(rawSeverity),
      status: status,
      assignee: assignee,
      scope: scope,
      recommendedAction: action,
      createdAt: time,
      sourceIp: sourceIp,
      country: country,
      targetPort: targetPort,
      protocol: protocol,
      payload: payload,
      isBlocked: isBlocked,
      abuseScore: abuseScore,
      timeline: stages,
    );
  }
}

class IncidentTimelineStage {
  final String stage;
  final String description;
  final String timestamp;
  final bool isCompleted;

  const IncidentTimelineStage({
    required this.stage,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  factory IncidentTimelineStage.fromJson(Map<String, dynamic> json) {
    return IncidentTimelineStage(
      stage: (json['stage'] ?? json['title'] ?? 'Review').toString(),
      description: (json['description'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? json['time'] ?? '—').toString(),
      isCompleted: json['is_completed'] == true || json['completed'] == true,
    );
  }
}
