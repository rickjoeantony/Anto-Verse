import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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

/// Interactive Canary Honeytoken Vault card with masked tripwire credentials.
class HoneytokenVaultCard extends StatelessWidget {
  final List<HoneytokenData> tokens;
  final Function(String hash)? onAudit;

  const HoneytokenVaultCard({
    super.key,
    required this.tokens,
    this.onAudit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0x102563EB),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Canary Honeytoken Vault',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Controlled tripwire credentials & cryptographic hashes',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Honeytoken integrity audit: 100% verified')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Verify All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                colors.brandPrimary.withOpacity(0.06),
              ),
              horizontalMargin: 12,
              columnSpacing: 18,
              headingTextStyle: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
                letterSpacing: 0.4,
              ),
              columns: const [
                DataColumn(label: Text('TOKEN ID')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('MASKED CREDENTIAL')),
                DataColumn(label: Text('AUDIT HASH')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: tokens.map((token) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        token.id,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          token.type,
                          style: TextStyle(fontSize: 10.5, color: colors.textPrimary),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        token.credential,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.warning,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        token.auditHash,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => onAudit?.call(token.auditHash),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Audit',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: colors.brandPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
