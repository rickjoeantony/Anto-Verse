// lib/features/overview/domain/overview_summary.dart

import '../../events/domain/severity_level.dart';
import 'dashboard_stats.dart';

/// Clean domain model representing deployment overview data and middle-man-3 stats.
class OverviewSummary {
  final String deploymentHealthStatus;
  final SeverityLevel deploymentHealthSeverity;
  final String? deploymentRegion;
  final int? criticalIncidentsCount;
  final int? highRiskEventsCount;
  final int? activeDeploymentsCount;
  final int? totalAttacksCount;
  final int? activeThreatsCount;
  final int? blockedIPsCount;
  final String? lastEventTimestamp;
  final String? recommendedActionTitle;
  final String? recommendedActionDescription;
  final String? organisationName;
  final List<double>? activityTrendData;
  final Map<String, double>? threatDistribution;
  final Map<String, double>? protocolActivity;
  final List<OverviewActivityItem> recentActivities;
  final DashboardStats? stats;
  final bool isBackendConnected;

  const OverviewSummary({
    required this.deploymentHealthStatus,
    required this.deploymentHealthSeverity,
    this.deploymentRegion,
    this.criticalIncidentsCount,
    this.highRiskEventsCount,
    this.activeDeploymentsCount,
    this.totalAttacksCount,
    this.activeThreatsCount,
    this.blockedIPsCount,
    this.lastEventTimestamp,
    this.recommendedActionTitle,
    this.recommendedActionDescription,
    this.organisationName,
    this.activityTrendData,
    this.threatDistribution,
    this.protocolActivity,
    this.recentActivities = const [],
    this.stats,
    this.isBackendConnected = false,
  });

  OverviewSummary copyWith({
    String? deploymentHealthStatus,
    SeverityLevel? deploymentHealthSeverity,
    String? deploymentRegion,
    int? criticalIncidentsCount,
    int? highRiskEventsCount,
    int? activeDeploymentsCount,
    int? totalAttacksCount,
    int? activeThreatsCount,
    int? blockedIPsCount,
    String? lastEventTimestamp,
    String? recommendedActionTitle,
    String? recommendedActionDescription,
    String? organisationName,
    List<double>? activityTrendData,
    Map<String, double>? threatDistribution,
    Map<String, double>? protocolActivity,
    List<OverviewActivityItem>? recentActivities,
    DashboardStats? stats,
    bool? isBackendConnected,
  }) {
    return OverviewSummary(
      deploymentHealthStatus: deploymentHealthStatus ?? this.deploymentHealthStatus,
      deploymentHealthSeverity: deploymentHealthSeverity ?? this.deploymentHealthSeverity,
      deploymentRegion: deploymentRegion ?? this.deploymentRegion,
      criticalIncidentsCount: criticalIncidentsCount ?? this.criticalIncidentsCount,
      highRiskEventsCount: highRiskEventsCount ?? this.highRiskEventsCount,
      activeDeploymentsCount: activeDeploymentsCount ?? this.activeDeploymentsCount,
      totalAttacksCount: totalAttacksCount ?? this.totalAttacksCount,
      activeThreatsCount: activeThreatsCount ?? this.activeThreatsCount,
      blockedIPsCount: blockedIPsCount ?? this.blockedIPsCount,
      lastEventTimestamp: lastEventTimestamp ?? this.lastEventTimestamp,
      recommendedActionTitle: recommendedActionTitle ?? this.recommendedActionTitle,
      recommendedActionDescription: recommendedActionDescription ?? this.recommendedActionDescription,
      organisationName: organisationName ?? this.organisationName,
      activityTrendData: activityTrendData ?? this.activityTrendData,
      threatDistribution: threatDistribution ?? this.threatDistribution,
      protocolActivity: protocolActivity ?? this.protocolActivity,
      recentActivities: recentActivities ?? this.recentActivities,
      stats: stats ?? this.stats,
      isBackendConnected: isBackendConnected ?? this.isBackendConnected,
    );
  }

  /// Default state when backend connection is pending
  factory OverviewSummary.awaitingBackend() {
    return const OverviewSummary(
      deploymentHealthStatus: 'Awaiting backend service',
      deploymentHealthSeverity: SeverityLevel.info,
      deploymentRegion: null,
      criticalIncidentsCount: null,
      highRiskEventsCount: null,
      activeDeploymentsCount: null,
      totalAttacksCount: null,
      activeThreatsCount: null,
      blockedIPsCount: null,
      lastEventTimestamp: null,
      recommendedActionTitle: 'Awaiting verified backend telemetry',
      recommendedActionDescription:
          'Security posture recommendations and honeynet metrics will appear here once connected to the LeukQuant analysis service.',
      organisationName: null,
      activityTrendData: null,
      threatDistribution: null,
      protocolActivity: null,
      recentActivities: [],
      stats: null,
      isBackendConnected: false,
    );
  }

  /// Parse real dashboard stats from GET /api/dashboard/stats
  factory OverviewSummary.fromJson(Map<String, dynamic> json) {
    final parsedStats = DashboardStats.fromJson(json);

    final status = (json['health_status'] ?? json['status'] ?? 'Active & Protected').toString();
    final rawSeverity = (json['health_severity'] ?? (parsedStats.criticalAlerts > 0 ? 'critical' : 'healthy')).toString();
    final region = json['region']?.toString() ?? json['deployment_region']?.toString() ?? 'Cloud Perimeter Cluster';

    final criticalCount = parsedStats.criticalAlerts;
    final highRiskCount = parsedStats.attacksToday > 0 ? parsedStats.attacksToday : parsedStats.activeThreats;
    final deploymentsCount = parsedStats.honeypots;

    final lastEvent = json['last_event_timestamp']?.toString() ?? json['last_event']?.toString() ?? 'Realtime stream active';
    final recTitle = json['recommended_action_title']?.toString() ??
        (criticalCount > 0 ? 'Review High-Threat Sensor Telemetry' : 'Automated Ingress Rules Enforced');
    final recDesc = json['recommended_action_description']?.toString() ??
        'Perimeter honeynet active. Automated quarantine filters blocking malicious ingress probes.';
    final orgName = json['organisation_name']?.toString() ?? json['tenant_name']?.toString() ?? 'Enterprise SOC';

    List<double>? trend;
    if (parsedStats.hourlyData.isNotEmpty) {
      trend = parsedStats.hourlyData.map((e) => e.attacks.toDouble()).toList();
    } else if (json['activity_trend'] is List) {
      trend = (json['activity_trend'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
          .toList();
    }

    Map<String, double>? threats;
    if (parsedStats.threatDistribution.isNotEmpty) {
      threats = {};
      for (final t in parsedStats.threatDistribution) {
        threats[t.level] = t.count.toDouble();
      }
    } else if (json['threat_distribution'] is Map) {
      threats = {};
      (json['threat_distribution'] as Map).forEach((k, v) {
        if (v is num) threats![k.toString()] = v.toDouble();
      });
    }

    Map<String, double>? protocols;
    if (parsedStats.topThreatVectors.isNotEmpty) {
      protocols = {};
      for (final v in parsedStats.topThreatVectors) {
        protocols[v.name] = v.count.toDouble();
      }
    } else if (json['protocol_activity'] is Map) {
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
      activeDeploymentsCount: deploymentsCount,
      totalAttacksCount: parsedStats.totalAttacks,
      activeThreatsCount: parsedStats.activeThreats,
      blockedIPsCount: parsedStats.blockedIPs,
      lastEventTimestamp: lastEvent,
      recommendedActionTitle: recTitle,
      recommendedActionDescription: recDesc,
      organisationName: orgName,
      activityTrendData: trend,
      threatDistribution: threats,
      protocolActivity: protocols,
      recentActivities: activities,
      stats: parsedStats,
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