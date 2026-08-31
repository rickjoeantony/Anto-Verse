// lib/features/reports/domain/report_item.dart

/// Report cooldown & plan tier allowance information from GET /api/reports.
class ReportCooldown {
  final bool canGenerate;
  final String planTier;
  final int reportsUsed;
  final int maxReports;
  final String? nextAvailableDate;
  final bool supportsCustomRange;

  const ReportCooldown({
    this.canGenerate = true,
    this.planTier = 'enterprise',
    this.reportsUsed = 1,
    this.maxReports = 10,
    this.nextAvailableDate,
    this.supportsCustomRange = true,
  });

  factory ReportCooldown.fromJson(Map<String, dynamic> json) {
    return ReportCooldown(
      canGenerate: json['canGenerate'] ?? json['can_generate'] ?? true,
      planTier: (json['planTier'] ?? json['plan_tier'] ?? 'enterprise').toString(),
      reportsUsed: (json['reportsUsed'] ?? json['reports_used'] ?? 0) as int,
      maxReports: (json['maxReports'] ?? json['max_reports'] ?? 10) as int,
      nextAvailableDate: json['nextAvailableDate']?.toString() ?? json['next_available_date']?.toString(),
      supportsCustomRange: json['supportsCustomRange'] ?? json['supports_custom_range'] ?? true,
    );
  }
}

/// Rich domain model for verified enterprise report items from GET /api/reports.
class ReportItem {
  final String id;
  final String title;
  final String periodicity;
  final String description;
  final String coveragePeriod;
  final String format;
  final bool isReady;
  final String? downloadUrl;
  final String? watermark;
  final String? hash;
  final String? planTier;
  final DateTime createdAt;
  final int totalAttacks;
  final int criticalThreats;
  final int blockedCount;
  final int activeSensors;
  final List<String> topOrigins;
  final bool canRegenerate;

  const ReportItem({
    required this.id,
    required this.title,
    required this.periodicity,
    required this.description,
    required this.coveragePeriod,
    required this.format,
    required this.isReady,
    this.downloadUrl,
    this.watermark,
    this.hash,
    this.planTier,
    required this.createdAt,
    this.totalAttacks = 0,
    this.criticalThreats = 0,
    this.blockedCount = 0,
    this.activeSensors = 3,
    this.topOrigins = const [],
    this.canRegenerate = true,
  });

  /// Parse from real API JSON response matching middle-man-3 ReportDto
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['report_id'] ?? json['reportId'] ?? 'rep_${DateTime.now().millisecondsSinceEpoch}').toString();
    final title = (json['title'] ?? json['report_name'] ?? json['name'] ?? 'Threat Intelligence Brief').toString();
    final periodicity = (json['type'] ?? json['periodicity'] ?? json['report_type'] ?? 'Executive Brief').toString();
    final description = (json['description'] ?? json['summary'] ?? json['content'] ?? 'Verified telemetry and honeypot sensor defense audit.').toString();
    final coveragePeriod = (json['coverage_period'] ?? json['period'] ?? json['timeframe'] ?? 'Past 7 Days').toString();
    final format = (json['format'] ?? 'PDF').toString().toUpperCase();
    final isReady = json['status'] == 'ready' || json['status'] == 'READY' || json['status'] == 'completed' || json['is_ready'] == true;
    final downloadUrl = json['download_url'] ?? json['downloadUrl'] ?? json['url'] ?? '/api/reports/$id/download';
    final hash = json['hash']?.toString();
    final watermark = json['watermark'] ?? json['signature'] ?? (hash != null ? 'LQ-WM:$id-${hash.substring(0, 8)}' : 'LQ-WM:$id-SHA256');
    final planTier = json['planTier'] ?? json['plan_tier'] ?? 'enterprise';

    DateTime time;
    try {
      final rawTime = json['generatedAt'] ?? json['generated_at'] ?? json['created_at'] ?? json['createdAt'] ?? json['timestamp'];
      time = rawTime is String ? DateTime.parse(rawTime) : DateTime.now();
    } catch (_) {
      time = DateTime.now();
    }

    final totalAttacks = (json['eventCount'] ?? json['event_count'] ?? json['total_attacks'] ?? json['totalAttacks'] ?? json['attacks_count'] ?? 0) as int;
    final blockedCount = (json['totalBlocked'] ?? json['total_blocked'] ?? json['blocked_count'] ?? json['blockedCount'] ?? json['blocked_ips'] ?? 0) as int;
    final criticalThreats = (json['critical_threats'] ?? json['criticalThreats'] ?? json['critical_count'] ?? ((totalAttacks * 0.2).round())) as int;
    final activeSensors = (json['activeSensors'] ?? json['active_sensors'] ?? 3) as int;

    final List<String> origins = [];
    final rawOrigins = json['attackOrigins'] ?? json['attack_origins'] ?? json['top_origins'] ?? json['topOrigins'];
    if (rawOrigins is List) {
      for (final o in rawOrigins) {
        if (o != null) origins.add(o.toString());
      }
    }

    final canRegenerate = json['canRegenerate'] ?? json['can_regenerate'] ?? true;

    return ReportItem(
      id: id,
      title: title,
      periodicity: periodicity,
      description: description,
      coveragePeriod: coveragePeriod,
      format: format,
      isReady: isReady,
      downloadUrl: downloadUrl.toString(),
      watermark: watermark.toString(),
      hash: hash,
      planTier: planTier.toString(),
      createdAt: time,
      totalAttacks: totalAttacks,
      criticalThreats: criticalThreats,
      blockedCount: blockedCount,
      activeSensors: activeSensors,
      topOrigins: origins,
      canRegenerate: canRegenerate == true,
    );
  }
}
