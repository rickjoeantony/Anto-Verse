// lib/features/overview/domain/dashboard_stats.dart

/// Geographic origin point of attacks for map/stats
class OriginGeo {
  final String country;
  final int count;
  final double? lat;
  final double? lng;

  const OriginGeo({
    required this.country,
    required this.count,
    this.lat,
    this.lng,
  });

  factory OriginGeo.fromJson(Map<String, dynamic> json) {
    return OriginGeo(
      country: (json['country'] ?? json['name'] ?? 'Unknown').toString(),
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : null,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : null,
    );
  }
}

/// Hourly attack trend data point
class HourlyDataPoint {
  final String hour;
  final int attacks;
  final int blocked;

  const HourlyDataPoint({
    required this.hour,
    required this.attacks,
    required this.blocked,
  });

  factory HourlyDataPoint.fromJson(Map<String, dynamic> json) {
    return HourlyDataPoint(
      hour: (json['hour'] ?? json['time'] ?? '00:00').toString(),
      attacks: (json['attacks'] is num) ? (json['attacks'] as num).toInt() : 0,
      blocked: (json['blocked'] is num) ? (json['blocked'] as num).toInt() : 0,
    );
  }
}

/// Threat distribution item
class ThreatDistributionItem {
  final String level;
  final int count;

  const ThreatDistributionItem({
    required this.level,
    required this.count,
  });

  factory ThreatDistributionItem.fromJson(Map<String, dynamic> json) {
    return ThreatDistributionItem(
      level: (json['level'] ?? json['threat_level'] ?? json['name'] ?? 'Info').toString(),
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
    );
  }
}

/// Top threat vector item
class TopThreatVector {
  final String name;
  final int count;

  const TopThreatVector({
    required this.name,
    required this.count,
  });

  factory TopThreatVector.fromJson(Map<String, dynamic> json) {
    return TopThreatVector(
      name: (json['name'] ?? json['vector'] ?? json['type'] ?? 'Generic Probe').toString(),
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
    );
  }
}

/// Clean domain model for GET /api/dashboard/stats
class DashboardStats {
  final int totalAttacks;
  final int activeThreats;
  final int blockedIPs;
  final int honeypots;
  final int attacksToday;
  final int criticalAlerts;
  final List<OriginGeo> origins;
  final List<HourlyDataPoint> hourlyData;
  final List<ThreatDistributionItem> threatDistribution;
  final List<TopThreatVector> topThreatVectors;
  final String systemUptime;

  const DashboardStats({
    required this.totalAttacks,
    required this.activeThreats,
    required this.blockedIPs,
    required this.honeypots,
    required this.attacksToday,
    required this.criticalAlerts,
    required this.origins,
    required this.hourlyData,
    required this.threatDistribution,
    required this.topThreatVectors,
    required this.systemUptime,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final totalAttacks = (json['totalAttacks'] ?? json['total_attacks'] ?? 0) is num
        ? (json['totalAttacks'] ?? json['total_attacks'] ?? 0 as num).toInt()
        : 0;

    final activeThreats = (json['activeThreats'] ?? json['active_threats'] ?? 0) is num
        ? (json['activeThreats'] ?? json['active_threats'] ?? 0 as num).toInt()
        : 0;

    final blockedIPs = (json['blockedIPs'] ?? json['blocked_ips'] ?? json['blockedIps'] ?? 0) is num
        ? (json['blockedIPs'] ?? json['blocked_ips'] ?? json['blockedIps'] ?? 0 as num).toInt()
        : 0;

    final honeypots = (json['honeypots'] ?? json['active_honeypots'] ?? json['active_deployments'] ?? 0) is num
        ? (json['honeypots'] ?? json['active_honeypots'] ?? json['active_deployments'] ?? 0 as num).toInt()
        : 0;

    final attacksToday = (json['attacksToday'] ?? json['attacks_today'] ?? json['high_risk_events'] ?? 0) is num
        ? (json['attacksToday'] ?? json['attacks_today'] ?? json['high_risk_events'] ?? 0 as num).toInt()
        : 0;

    final criticalAlerts = (json['criticalAlerts'] ?? json['critical_alerts'] ?? json['critical_incidents'] ?? 0) is num
        ? (json['criticalAlerts'] ?? json['critical_alerts'] ?? json['critical_incidents'] ?? 0 as num).toInt()
        : 0;

    final systemUptime = (json['systemUptime'] ?? json['system_uptime'] ?? json['uptime'] ?? '99.98%').toString();

    // Origins
    final List<OriginGeo> originsList = [];
    if (json['origins'] is List) {
      for (final item in json['origins'] as List) {
        if (item is Map<String, dynamic>) {
          originsList.add(OriginGeo.fromJson(item));
        }
      }
    }

    // Hourly Data
    final List<HourlyDataPoint> hourlyList = [];
    if (json['hourlyData'] is List) {
      for (final item in json['hourlyData'] as List) {
        if (item is Map<String, dynamic>) {
          hourlyList.add(HourlyDataPoint.fromJson(item));
        }
      }
    } else if (json['activity_trend'] is List) {
      final list = json['activity_trend'] as List;
      for (int i = 0; i < list.length; i++) {
        final val = (list[i] is num) ? (list[i] as num).toInt() : 0;
        hourlyList.add(HourlyDataPoint(hour: '${i * 4}:00', attacks: val, blocked: (val * 0.8).round()));
      }
    }

    // Threat Distribution
    final List<ThreatDistributionItem> threatDistList = [];
    if (json['threatDistribution'] is List) {
      for (final item in json['threatDistribution'] as List) {
        if (item is Map<String, dynamic>) {
          threatDistList.add(ThreatDistributionItem.fromJson(item));
        }
      }
    } else if (json['threat_distribution'] is Map) {
      (json['threat_distribution'] as Map).forEach((k, v) {
        final c = (v is num) ? v.toInt() : 0;
        threatDistList.add(ThreatDistributionItem(level: k.toString(), count: c));
      });
    }

    // Top Threat Vectors
    final List<TopThreatVector> vectorsList = [];
    if (json['topThreatVectors'] is List) {
      for (final item in json['topThreatVectors'] as List) {
        if (item is Map<String, dynamic>) {
          vectorsList.add(TopThreatVector.fromJson(item));
        }
      }
    } else if (json['top_threat_vectors'] is List) {
      for (final item in json['top_threat_vectors'] as List) {
        if (item is Map<String, dynamic>) {
          vectorsList.add(TopThreatVector.fromJson(item));
        }
      }
    }

    return DashboardStats(
      totalAttacks: totalAttacks,
      activeThreats: activeThreats,
      blockedIPs: blockedIPs,
      honeypots: honeypots,
      attacksToday: attacksToday,
      criticalAlerts: criticalAlerts,
      origins: originsList,
      hourlyData: hourlyList,
      threatDistribution: threatDistList,
      topThreatVectors: vectorsList,
      systemUptime: systemUptime,
    );
  }
}
