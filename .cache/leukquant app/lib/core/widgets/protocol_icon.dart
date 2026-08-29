// lib/core/widgets/protocol_icon.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Clean bare protocol indicator with vector icon and label.
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
        return Icons.lock_outline_rounded;
      case 'HTTP':
        return Icons.language_rounded;
      case 'POSTGRESQL':
      case 'SQL':
      case 'MYSQL':
        return Icons.storage_rounded;
      case 'DNS':
        return Icons.alt_route_rounded;
      case 'RDP':
      case 'VNC':
        return Icons.desktop_windows_rounded;
      case 'FTP':
      case 'SFTP':
        return Icons.folder_shared_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final icon = _getIcon(protocol);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: isCompact ? 12 : 14,
          color: colors.brandPrimary.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 4.5),
        Text(
          protocol.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: isCompact ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
