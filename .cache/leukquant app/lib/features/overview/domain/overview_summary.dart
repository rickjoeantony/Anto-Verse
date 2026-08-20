// lib/features/overview/domain/overview_summary.dart

import '../../events/domain/severity_level.dart';

/// Clean domain model representing deployment overview data.
class OverviewSummary {
  final String deploymentHealthStatus;
  final SeverityLevel deploymentHealthSeverity;
  final String? deploymentRegion;
  final int? criticalIncidentsCount;
  final int? highRiskEventsCount;
  final String? lastEventTimestamp;
  final String? recommendedActionTitle;
  final String? recommendedActionDescription;
  final String? organisationName;
  final List<double>? activityTrendData;
  final Map<String, double>? threatDistribution;
  final Map<String, double>? protocolActivity;
  final List<OverviewActivityItem> recentActivities;
  final bool isBackendConnected;

  const OverviewSummary({
    required this.deploymentHealthStatus,
    required this.deploymentHealthSeverity,
    this.deploymentRegion,
    this.criticalIncidentsCount,
    this.highRiskEventsCount,
    this.lastEventTimestamp,
    this.recommendedActionTitle,
    this.recommendedActionDescription,
    this.organisationName,
    this.activityTrendData,
    this.threatDistribution,
    this.protocolActivity,
    this.recentActivities = const [],
    this.isBackendConnected = false,
  });

  /// Default state when backend connection is pending
  factory OverviewSummary.awaitingBackend() {
    return const OverviewSummary(
      deploymentHealthStatus: 'Awaiting backend service',
      deploymentHealthSeverity: SeverityLevel.info,
      deploymentRegion: null,
      criticalIncidentsCount: null,
      highRiskEventsCount: null,
      lastEventTimestamp: null,
      recommendedActionTitle: 'Awaiting verified backend telemetry',
      recommendedActionDescription:
          'Security posture recommendations and honeynet metrics will appear here once connected to the LeukQuant analysis service.',
      organisationName: null,
      activityTrendData: null,
      threatDistribution: null,
      protocolActivity: null,
      recentActivities: [],
      isBackendConnected: false,
    );
  }

  /// Parse real dashboard stats from GET /api/dashboard/stats
  factory OverviewSummary.fromJson(Map<String, dynamic> json) {
    final status = (json['health_status'] ?? json['status'] ?? 'Operational / Standby').toString();
    final rawSeverity = (json['health_severity'] ?? 'healthy').toString();
    final region = json['region']?.toString() ?? json['deployment_region']?.toString();
    final criticalCount = json['critical_incidents'] is num ? (json['critical_incidents'] as num).toInt() : null;
    final highRiskCount = json['high_risk_events'] is num ? (json['high_risk_events'] as num).toInt() : null;
    final lastEvent = json['last_event_timestamp']?.toString() ?? json['last_event']?.toString();
    final recTitle = json['recommended_action_title']?.toString() ?? json['recommendation_title']?.toString();
    final recDesc = json['recommended_action_description']?.toString() ?? json['recommendation_desc']?.toString();
    final orgName = json['organisation_name']?.toString() ?? json['tenant_name']?.toString();

    List<double>? trend;
    if (json['activity_trend'] is List) {
      trend = (json['activity_trend'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
          .toList();
    }

    Map<String, double>? threats;
    if (json['threat_distribution'] is Map) {
      threats = {};
      (json['threat_distribution'] as Map).forEach((k, v) {
        if (v is num) threats![k.toString()] = v.toDouble();
      });
    }

    Map<String, double>? protocols;
    if (json['protocol_activity'] is Map) {
      protocols = {};
      (json['protocol_activity'] as Map).forEach((k, v) {
        if (v is num) protocols![k.toString()] = v.toDouble();
      });
    }

    List<OverviewActivityItem> activities = [];
    if (json['recent_activities'] is List) {
      activities = (json['recent_activities'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => OverviewActivityItem.fromJson(item))
          .toList();
    }

    return OverviewSummary(
      deploymentHealthStatus: status,
      deploymentHealthSeverity: SeverityLevel.fromString(rawSeverity),
      deploymentRegion: region,
      criticalIncidentsCount: criticalCount,
      highRiskEventsCount: highRiskCount,
      lastEventTimestamp: lastEvent,
      recommendedActionTitle: recTitle,
      recommendedActionDescription: recDesc,
      organisationName: orgName,
      activityTrendData: trend,
      threatDistribution: threats,
      protocolActivity: protocols,
      recentActivities: activities,
      isBackendConnected: true,
    );
  }
}

class OverviewActivityItem {
  final String id;
  final String title;
  final String protocol;
  final String timestamp;
  final SeverityLevel severity;
  final String description;

  const OverviewActivityItem({
    required this.id,
    required this.title,
    required this.protocol,
    required this.timestamp,
    required this.severity,
    required this.description,
  });

  factory OverviewActivityItem.fromJson(Map<String, dynamic> json) {
    return OverviewActivityItem(
      id: (json['id'] ?? 'ACT-UNKNOWN').toString(),
      title: (json['title'] ?? 'Telemetry Activity').toString(),
      protocol: (json['protocol'] ?? 'TCP').toString().toUpperCase(),
      timestamp: (json['timestamp'] ?? json['time'] ?? 'Just now').toString(),
      severity: SeverityLevel.fromString((json['severity'] ?? 'info').toString()),
      description: (json['description'] ?? '').toString(),
    );
  }
}
