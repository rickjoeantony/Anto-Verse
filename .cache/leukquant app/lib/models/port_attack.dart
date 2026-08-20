// lib/models/port_attack.dart

/// Model representing an attacked port and its count.
class PortAttack {
  final String port;
  final int count;

  const PortAttack({required this.port, required this.count});

  /// Create a [PortAttack] from JSON map.
  factory PortAttack.fromJson(Map<String, dynamic> json) {
    return PortAttack(
      port: json['port'] as String,
      count: json['count'] as int,
    );
  }

  /// Convert the instance to JSON.
  Map<String, dynamic> toJson() => {
        'port': port,
        'count': count,
      };
}
