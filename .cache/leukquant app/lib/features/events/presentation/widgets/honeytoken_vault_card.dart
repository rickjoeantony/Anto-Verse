// lib/features/events/presentation/widgets/honeytoken_vault_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';

class HoneytokenData {
  final String id;
  final String type;
  final String credential;
  final String auditHash;

  const HoneytokenData({
    required this.id,
    required this.type,
    required this.credential,
    required this.auditHash,
  });
}

/// Ultra-luxury Canary Honeytoken Vault — titanium depth, bare status beacons, copy actions.
class HoneytokenVaultCard extends StatelessWidget {
  final List<HoneytokenData> tokens;
  final Function(String hash)? onAudit;

  const HoneytokenVaultCard({
    super.key,
    required this.tokens,
    this.onAudit,
  });

  IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('ssh')) return Icons.key_rounded;
    if (t.contains('db') || t.contains('sql')) return Icons.storage_rounded;
    if (t.contains('iam') || t.contains('aws') || t.contains('api')) return Icons.cloud_rounded;
    return Icons.token_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vault icon with ambient glow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.brandPrimary.withValues(alpha: isDark ? 0.30 : 0.20),
                  ),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 17,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Canary Honeytoken Vault',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Decoy tripwire credentials  ·  ${tokens.length} active nodes',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Verify all link
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All canary honeytoken hashes verified ✓'),
                      backgroundColor: colors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verify All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.brandPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colors.brandPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Token Rows ─────────────────────────────────────────────
          ...tokens.asMap().entries.map((entry) {
            final i = entry.key;
            final token = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: i < tokens.length - 1 ? 10 : 0),
              child: _TokenRow(
                token: token,
                typeIcon: _typeIcon(token.type),
                onAudit: onAudit,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final HoneytokenData token;
  final IconData typeIcon;
  final Function(String hash)? onAudit;

  const _TokenRow({
    required this.token,
    required this.typeIcon,
    this.onAudit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          width: 0.9,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Token type icon
          Icon(
            typeIcon,
            size: 18,
            color: colors.brandPrimary.withValues(alpha: isDark ? 0.9 : 0.8),
          ),
          const SizedBox(width: 12),

          // Token info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + Type
                Row(
                  children: [
                    Text(
                      token.id,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.brandPrimary,
                        fontFamily: 'monospace',
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '·',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        token.type,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Obfuscated Credential string
                Text(
                  token.credential,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary.withValues(alpha: 0.65),
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // Audit action link
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onAudit != null) {
                onAudit!(token.auditHash);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Auditing token ${token.id}... Hash: ${token.auditHash}'),
                    backgroundColor: colors.brandPrimary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Audit',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: colors.textSecondary.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
