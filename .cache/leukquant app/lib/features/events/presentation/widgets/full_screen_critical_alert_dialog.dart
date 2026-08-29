// lib/features/events/presentation/widgets/full_screen_critical_alert_dialog.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/security_event.dart';
import 'ip_sessions_sheet.dart';

/// Full-screen emergency incident HUD triggered on Critical Honeypot/Decoy Ingress.
class FullScreenCriticalAlertDialog extends StatefulWidget {
  final SecurityEvent event;

  const FullScreenCriticalAlertDialog({super.key, required this.event});

  static Future<void> show(BuildContext context, SecurityEvent event) async {
    // Play loud acoustic emergency siren
    unawaited(NotificationService.instance.playTone('cyberRadar'));

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Critical Alert',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) => FullScreenCriticalAlertDialog(event: event),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<FullScreenCriticalAlertDialog> createState() => _FullScreenCriticalAlertDialogState();
}

class _FullScreenCriticalAlertDialogState extends State<FullScreenCriticalAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Periodic tactile emergency pulse
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final event = widget.event;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background blur & glowing red vignette
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.4,
                    colors: [
                      const Color(0xFFE11D48).withValues(alpha: 0.45),
                      const Color(0xFF0F172A).withValues(alpha: 0.95),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Top Emergency Banner with Animated Pulsing Beacon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.2 + (_pulseController.value * 0.2)),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFF43F5E),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE11D48).withValues(alpha: _pulseController.value * 0.6),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'CRITICAL THREAT INGRESS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Central Attack Card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Attack Type Title
                              Text(
                                event.type.isNotEmpty ? event.type : 'UNAUTHORIZED SENSOR INTRUSION',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Active honeypot decoy sensor triggered. Malicious ingress detected.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: Color(0xFF334155), height: 1),
                              const SizedBox(height: 18),

                              // Key Telemetry Metrics
                              _buildMetricRow('Attacker IP', event.sourceIp, isHighlighted: true),
                              _buildMetricRow('Geolocation', '${event.country} (${event.countryCode.isNotEmpty ? event.countryCode : "Global"})'),
                              _buildMetricRow('Target Decoy', '${event.honeypot} (Port ${event.destinationPort.isNotEmpty ? event.destinationPort : event.protocol})'),
                              _buildMetricRow('Protocol', event.protocol.toUpperCase()),
                              _buildMetricRow('Threat Severity', 'LEVEL ${event.threatLevel} / 5 (CRITICAL)', color: const Color(0xFFF43F5E)),
                              _buildMetricRow('Abuse Confidence', '${event.abuseScore.toStringAsFixed(1)} %', color: const Color(0xFFFBBF24)),

                              if (event.payload.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'INTERCEPTED PAYLOAD DUMP',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF334155)),
                                  ),
                                  child: Text(
                                    event.payload,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tactical Actions (Zero Overflow Guaranteed)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              IpSessionsSheet.show(context, event.sourceIp);
                            },
                            icon: const Icon(Icons.shield_outlined, size: 20),
                            label: const Text(
                              'INSPECT IP FORENSICS & SESSIONS',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, letterSpacing: 0.5),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Color(0xFF475569)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Acknowledge & Neutralize',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? (isHighlighted ? const Color(0xFF38BDF8) : Colors.white),
                fontSize: isHighlighted ? 14 : 13,
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                fontFamily: isHighlighted ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}