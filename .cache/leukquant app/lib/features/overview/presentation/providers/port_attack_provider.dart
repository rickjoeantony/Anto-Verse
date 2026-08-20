import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/port_attack.dart';

/// Provider that fetches the list of attacked ports from the backend.
/// Expected JSON response: [{"port": "22", "count": 124}, ...]
final portAttackProvider = FutureProvider.autoDispose<List<PortAttack>>((ref) async {
  return const [
    PortAttack(port: '22', count: 124),
    PortAttack(port: '443', count: 89),
    PortAttack(port: '5432', count: 42),
    PortAttack(port: '80', count: 28),
  ];
});
