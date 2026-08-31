// lib/features/overview/presentation/widgets/interactive_world_threat_map.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../events/domain/security_event.dart';

/// Comprehensive Cyber Threat World Map Painter & Interactive Visualizer
class InteractiveWorldThreatMap extends StatefulWidget {
  final List<SecurityEvent> events;
  final bool isFullScreen;
  final String selectedProtocol;
  final Function(SecurityEvent)? onSelectEvent;

  const InteractiveWorldThreatMap({
    super.key,
    required this.events,
    this.isFullScreen = false,
    this.selectedProtocol = 'ALL',
    this.onSelectEvent,
  });

  @override
  State<InteractiveWorldThreatMap> createState() => _InteractiveWorldThreatMapState();
}

class _InteractiveWorldThreatMapState extends State<InteractiveWorldThreatMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  SecurityEvent? _inspectedEvent;
  Offset? _tooltipPosition;

  // Real world coordinates for common attack origin countries
  static const Map<String, Offset> _countryCoords = {
    'US': Offset(-98.0, 39.0),
    'UNITED STATES': Offset(-98.0, 39.0),
    'CN': Offset(104.0, 35.0),
    'CHINA': Offset(104.0, 35.0),
    'RU': Offset(95.0, 60.0),
    'RUSSIA': Offset(95.0, 60.0),
    'DE': Offset(10.4, 51.1),
    'GERMANY': Offset(10.4, 51.1),
    'NL': Offset(5.2, 52.1),
    'NETHERLANDS': Offset(5.2, 52.1),
    'IN': Offset(78.9, 20.5),
    'INDIA': Offset(78.9, 20.5),
    'BR': Offset(-51.9, -14.2),
    'BRAZIL': Offset(-51.9, -14.2),
    'GB': Offset(-3.4, 55.3),
    'UNITED KINGDOM': Offset(-3.4, 55.3),
    'FR': Offset(2.2, 46.2),
    'FRANCE': Offset(2.2, 46.2),
    'JP': Offset(138.2, 36.2),
    'JAPAN': Offset(138.2, 36.2),
    'AU': Offset(133.7, -25.2),
    'AUSTRALIA': Offset(133.7, -25.2),
    'SG': Offset(103.8, 1.3),
    'SINGAPORE': Offset(103.8, 1.3),
    'KR': Offset(127.7, 35.9),
    'SOUTH KOREA': Offset(127.7, 35.9),
  };

  // Honeynet Sensor Gateway Targets
  static const List<Map<String, dynamic>> _honeynetGateways = [
    {'name': 'US-East Core (Ghost-Net)', 'lng': -77.0, 'lat': 38.9, 'color': Color(0xFF00E5FF)},
    {'name': 'EU-Central Decoy (Tarpit-1)', 'lng': 8.6, 'lat': 50.1, 'color': Color(0xFF38EF7D)},
    {'name': 'AP-South Ingress (Canary-9)', 'lng': 72.8, 'lat': 19.0, 'color': Color(0xFFFF9F0A)},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Offset _latLngToCanvas(double lng, double lat, Size size) {
    // Equirectangular / Miller Projection conversion
    final x = (lng + 180.0) * (size.width / 360.0);
    final y = (90.0 - lat) * (size.height / 180.0);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredEvents = widget.events.where((e) {
      if (widget.selectedProtocol == 'ALL') return true;
      return e.protocol.toUpperCase() == widget.selectedProtocol.toUpperCase();
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight.isFinite ? constraints.maxHeight : 240);

        return Stack(
          children: [
            // Interactive Map Canvas
            GestureDetector(
              onTapDown: (details) {
                _handleTap(details.localPosition, size, filteredEvents);
              },
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: _WorldThreatMapPainter(
                      progress: _animController.value,
                      events: filteredEvents,
                      colors: colors,
                      isDark: isDark,
                      gateways: _honeynetGateways,
                      countryCoords: _countryCoords,
                      inspectedEvent: _inspectedEvent,
                    ),
                  );
                },
              ),
            ),

            // Live HUD Tooltip on tapped node
            if (_inspectedEvent != null && _tooltipPosition != null) ...[
              Positioned(
                left: max(10, min(size.width - 240, _tooltipPosition!.dx - 110)),
                top: max(10, min(size.height - 110, _tooltipPosition!.dy - 95)),
                child: GestureDetector(
                  onTap: () {
                    if (widget.onSelectEvent != null) {
                      widget.onSelectEvent!(_inspectedEvent!);
                    }
                  },
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xE60B101E) : const Color(0xF2FFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _inspectedEvent!.threatLevel >= 4
                            ? colors.critical.withValues(alpha: 0.8)
                            : colors.brandPrimary.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_inspectedEvent!.threatLevel >= 4 ? colors.critical : colors.brandPrimary)
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _inspectedEvent!.threatLevel >= 4 ? colors.critical : colors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_inspectedEvent!.sourceIp} (${_inspectedEvent!.countryCode})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _inspectedEvent = null),
                              child: Icon(Icons.close, size: 14, color: colors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_inspectedEvent!.protocol} · Port ${_inspectedEvent!.destinationPort} → ${_inspectedEvent!.honeypot}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.brandPrimary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Abuse Score: ${_inspectedEvent!.abuseScore.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                            ),
                            Text(
                              _inspectedEvent!.isBlocked ? '✓ BLOCKED' : 'TRAPPED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _inspectedEvent!.isBlocked ? colors.success : colors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleTap(Offset localPos, Size size, List<SecurityEvent> events) {
    for (int i = 0; i < events.length; i++) {
      final e = events[i];
      final key = e.countryCode.toUpperCase().isNotEmpty ? e.countryCode.toUpperCase() : e.country.toUpperCase();
      final coord = _countryCoords[key] ?? Offset(-98.0 + (i % 8) * 35.0, 39.0 - (i % 5) * 15.0);
      final canvasPos = _latLngToCanvas(coord.dx, coord.dy, size);

      if ((canvasPos - localPos).distance < 20.0) {
        HapticFeedback.selectionClick();
        setState(() {
          _inspectedEvent = e;
          _tooltipPosition = canvasPos;
        });
        return;
      }
    }

    setState(() {
      _inspectedEvent = null;
      _tooltipPosition = null;
    });
  }
}

/// Custom painter rendering high-tech dot-matrix continents, sensor nodes, and parabolic attack arcs
class _WorldThreatMapPainter extends CustomPainter {
  final double progress;
  final List<SecurityEvent> events;
  final AppColorScheme colors;
  final bool isDark;
  final List<Map<String, dynamic>> gateways;
  final Map<String, Offset> countryCoords;
  final SecurityEvent? inspectedEvent;

  _WorldThreatMapPainter({
    required this.progress,
    required this.events,
    required this.colors,
    required this.isDark,
    required this.gateways,
    required this.countryCoords,
    this.inspectedEvent,
  });

  Offset _toCanvas(double lng, double lat, Size size) {
    final x = (lng + 180.0) * (size.width / 360.0);
    final y = (90.0 - lat) * (size.height / 180.0);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Subtle Cyber Grid Latitude & Longitude Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 0.6;

    for (int lon = -180; lon <= 180; lon += 45) {
      final x = (lon + 180.0) * (size.width / 360.0);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int lat = -60; lat <= 80; lat += 30) {
      final y = (90.0 - lat) * (size.height / 180.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Vector Continent Outline Dot Matrix (Landmass Silhouettes)
    _drawContinents(canvas, size);

    // 3. Draw Honeynet Gateway Target Nodes
    for (final gw in gateways) {
      final pos = _toCanvas(gw['lng'] as double, gw['lat'] as double, size);
      final gwColor = gw['color'] as Color;

      // Gateway Core
      final corePaint = Paint()..color = gwColor;
      canvas.drawCircle(pos, 4.0, corePaint);

      // Radar Concentric Waves on Gateway
      final waveRadius = (progress * 18.0) % 18.0;
      final wavePaint = Paint()
        ..color = gwColor.withValues(alpha: max(0.0, 1.0 - (waveRadius / 18.0)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(pos, waveRadius + 4.0, wavePaint);
    }

    // 4. Draw Parabolic Ballistic Attack Arcs & Origin Blips
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < events.length; i++) {
      final e = events[i];
      final key = e.countryCode.toUpperCase().isNotEmpty ? e.countryCode.toUpperCase() : e.country.toUpperCase();
      final originCoords = countryCoords[key] ?? Offset(-98.0 + (i % 8) * 35.0, 39.0 - (i % 5) * 15.0);
      final originPos = _toCanvas(originCoords.dx, originCoords.dy, size);

      final targetGw = gateways[i % gateways.length];
      final targetPos = _toCanvas(targetGw['lng'] as double, targetGw['lat'] as double, size);

      final isCritical = e.threatLevel >= 4;
      final arcColor = isCritical ? colors.critical : colors.brandPrimary;

      // Calculate smooth quadratic Bezier curve control point (arching upwards)
      final midX = (originPos.dx + targetPos.dx) / 2;
      final midY = min(originPos.dy, targetPos.dy) - (originPos - targetPos).distance * 0.28;
      final controlPoint = Offset(midX, midY);

      final path = Path()
        ..moveTo(originPos.dx, originPos.dy)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, targetPos.dx, targetPos.dy);

      // Draw faint background trajectory line
      arcPaint
        ..color = arcColor.withValues(alpha: 0.18)
        ..strokeWidth = 0.9;
      canvas.drawPath(path, arcPaint);

      // Projectile animation along curve
      final arcOffset = (progress + (i * 0.18)) % 1.0;
      final t = arcOffset;
      // Quadratic Bezier interpolation formula: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
      final currentX = pow(1 - t, 2) * originPos.dx + 2 * (1 - t) * t * controlPoint.dx + pow(t, 2) * targetPos.dx;
      final currentY = pow(1 - t, 2) * originPos.dy + 2 * (1 - t) * t * controlPoint.dy + pow(t, 2) * targetPos.dy;
      final projectilePos = Offset(currentX, currentY);

      // Projectile Glowing Head
      headPaint.color = arcColor;
      canvas.drawCircle(projectilePos, isCritical ? 3.5 : 2.5, headPaint);

      // Glow halo
      final haloPaint = Paint()..color = arcColor.withValues(alpha: 0.4);
      canvas.drawCircle(projectilePos, isCritical ? 7.0 : 5.0, haloPaint);

      // Attacker Origin Blip
      final originPaint = Paint()..color = (isCritical ? colors.critical : colors.warning).withValues(alpha: 0.85);
      canvas.drawCircle(originPos, 3.0, originPaint);
    }
  }

  void _drawContinents(Canvas canvas, Size size) {
    // High performance continent polygon / dot matrix clusters
    final dotPaint = Paint()
      ..color = (isDark ? const Color(0xFF2A364F) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.fill;

    // Approximate continent representative clusters (North America, South America, Europe, Africa, Asia, Australia)
    final clusters = [
      // North America
      ..._createCluster(-120, -70, 30, 60, 12),
      // South America
      ..._createCluster(-75, -45, -35, 10, 8),
      // Europe
      ..._createCluster(-5, 35, 38, 65, 10),
      // Africa
      ..._createCluster(-10, 45, -30, 30, 14),
      // Asia
      ..._createCluster(50, 130, 15, 65, 20),
      // Australia
      ..._createCluster(115, 150, -35, -15, 6),
    ];

    for (final pt in clusters) {
      final pos = _toCanvas(pt.dx, pt.dy, size);
      canvas.drawCircle(pos, 1.3, dotPaint);
    }
  }

  List<Offset> _createCluster(double minLng, double maxLng, double minLat, double maxLat, int count) {
    final list = <Offset>[];
    final stepLng = (maxLng - minLng) / (count / 2);
    final stepLat = (maxLat - minLat) / (count / 2);
    for (double lng = minLng; lng <= maxLng; lng += stepLng) {
      for (double lat = minLat; lat <= maxLat; lat += stepLat) {
        list.add(Offset(lng, lat));
      }
    }
    return list;
  }

  @override
  bool shouldRepaint(covariant _WorldThreatMapPainter oldDelegate) => true;
}
