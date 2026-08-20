// lib/features/reports/domain/report_item.dart

/// Domain model for verified enterprise report items from GET /api/reports.
class ReportItem {
  final String id;
  final String title;
  final String periodicity;
  final String description;
  final String coveragePeriod;
  final String format;
  final bool isReady;
  final String? downloadUrl;

  const ReportItem({
    required this.id,
    required this.title,
    required this.periodicity,
    required this.description,
    required this.coveragePeriod,
    required this.format,
    required this.isReady,
    this.downloadUrl,
  });

  /// Parse from real staging API JSON response
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: (json['id'] ?? json['report_id'] ?? 'REP-UNKNOWN').toString(),
      title: (json['title'] ?? 'Security Report').toString(),
      periodicity: (json['periodicity'] ?? json['type'] ?? 'On-Demand').toString(),
      description: (json['description'] ?? 'Automated enterprise security telemetry audit report.').toString(),
      coveragePeriod: (json['coverage_period'] ?? json['period'] ?? 'Recent Activity').toString(),
      format: (json['format'] ?? 'PDF').toString().toUpperCase(),
      isReady: json['is_ready'] == true || json['status'] == 'ready' || json['status'] == 'completed',
      downloadUrl: json['download_url']?.toString(),
    );
  }
}
