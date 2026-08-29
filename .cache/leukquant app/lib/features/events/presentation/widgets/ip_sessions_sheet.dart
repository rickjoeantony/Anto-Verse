// lib/features/events/presentation/widgets/ip_sessions_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_sheet.dart';
import '../../domain/ip_session.dart';

final ipSessionsProvider =
    FutureProvider.family<IpSessionsData, String>((ref, ip) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.getIpSessions(ip);
    return IpSessionsData.fromJson(ip, response.data);
  } catch (_) {
    return IpSessionsData(ip: ip, totalSessions: 0, sessions: const []);
  }
});

/// IP Sessions bottom sheet with security warning, password masking, and read-only commands.
class IpSessionsSheet extends ConsumerWidget {
  final String ip;

  const IpSessionsSheet({
    super.key,
    required this.ip,
  });

  static void show(BuildContext context, String ip) {
    LiquidGlassSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => IpSessionsSheet(ip: ip),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(ipSessionsProvider(ip));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.terminal_rounded, size: 20, color: colors.brandPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'IP Sessions: $ip',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
                      border: Border.all(color: colors.glassBorder, width: 1),
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),

          // Security Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_clock_rounded, size: 16, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sensitive activity data. Authorised review only.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sessions List
          Flexible(
            child: sessionsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to retrieve IP session telemetry.',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
              data: (data) {
                if (data.sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 40, color: colors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No recorded sessions for $ip.',
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: data.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = data.sessions[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                session.sessionId,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                              ),
                              Text(
                                '${session.protocol} • ${session.honeypot}',
                                style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Masked Credentials
                          if (session.credentials.isNotEmpty) ...[
                            Text(
                              'Captured Credentials (Masked):',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.brandPrimary),
                            ),
                            const SizedBox(height: 4),
                            ...session.credentials.map(
                              (c) => Text(
                                '${c.username} ••••••••',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Read-only Commands
                          if (session.commands.isNotEmpty) ...[
                            Text(
                              'Read-Only Command Stream:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF13171F) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: session.commands
                                    .map(
                                      (cmd) => SelectableText(
                                        '\$ $cmd',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
