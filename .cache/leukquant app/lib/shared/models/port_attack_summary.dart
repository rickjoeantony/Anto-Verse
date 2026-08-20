// lib/shared/models/port_attack_summary.dart

/// Model representing a targeted decoy port and its attack count.
/// Supports multiple possible backend field names for the port.
class PortAttackSummary {
  final String port;
  final int count;

  const PortAttackSummary({required this.port, required this.count});

  /// Creates an instance from JSON, looking for any of the allowed port keys.
  factory PortAttackSummary.fromJson(Map<String, dynamic> json) {
    const possibleKeys = [
      'target_port',
      'honeypot_port',
      'decoy_port',
      'targetPort',
      'honeypotPort',
      'decoyPort',
    ];
    String? portValue;
    for (final key in possibleKeys) {
      if (json.containsKey(key) && json[key] != null) {
        portValue = json[key].toString();
        break;
      }
    }
    if (portValue == null) {
      throw Exception('No target port field found in response');
    }
    final count = json['count'] as int? ?? json['attackCount'] as int? ?? 0;
    return PortAttackSummary(port: portValue, count: count);
  }

  Map<String, dynamic> toJson() => {'port': port, 'count': count};
}
