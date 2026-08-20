// lib/core/widgets/protocol_icon.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean branded protocol badge with vector icon and label.
class ProtocolBadge extends StatelessWidget {
  final String protocol;
  final bool isCompact;

  const ProtocolBadge({
    super.key,
    required this.protocol,
    this.isCompact = false,
  });

  IconData _getIcon(String proto) {
    switch (proto.toUpperCase()) {
      case 'SSH':
        return Icons.terminal_rounded;
      case 'HTTPS':
      case 'TLS':
      case 'HTTP':
        return Icons.language_rounded;
      case 'POSTGRESQL':
      case 'SQL':
      case 'MYSQL':
        return Icons.storage_rounded;
      case 'DNS':
        return Icons.dns_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final icon = _getIcon(protocol);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colors.brandPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: colors.brandPrimary),
          const SizedBox(width: 4),
          Text(
            protocol.toUpperCase(),
            style: TextStyle(
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
