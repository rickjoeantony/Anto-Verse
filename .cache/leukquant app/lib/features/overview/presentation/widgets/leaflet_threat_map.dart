// lib/features/overview/presentation/widgets/leaflet_threat_map.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/network/api_client.dart';
import '../../../events/domain/security_event.dart';
import '../../../events/presentation/widgets/event_details_sheet.dart';
import '../../domain/dashboard_stats.dart';

/// Leaflet Threat Map Mode
enum ThreatMapTileStyle {
  darkCyber,
  openStreetMap,
  cartoVoyager,
}

/// Ultra-High Fidelity Leaflet Threat Intelligence Map (Exact Web Dashboard Parity)
class LeafletThreatMap extends ConsumerStatefulWidget {
  final List<SecurityEvent> events;
  final List<OriginGeo>? origins;
  final bool isInteractive;
  final String selectedProtocol;
  final Function(SecurityEvent)? onSelectEvent;

  const LeafletThreatMap({
    super.key,
    required this.events,
    this.origins,
    this.isInteractive = true,
    this.selectedProtocol = 'ALL',
    this.onSelectEvent,
  });

  @override
  ConsumerState<LeafletThreatMap> createState() => _LeafletThreatMapState();
}

class _LeafletThreatMapState extends ConsumerState<LeafletThreatMap> with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  late final AnimationController _arcAnimController;
  Timer? _dynamicAttackTimer;

  SecurityEvent? _selectedEvent;
  OriginGeo? _selectedOrigin;
  bool _showLegend = false;
  LatLng? _userLocation;
  String? _userCity;
  ThreatMapTileStyle _tileStyle = ThreatMapTileStyle.darkCyber;

  // Exact Web Dashboard Honeypots from AttackMap.tsx
  static const List<Map<String, dynamic>> _honeypots = [
    {'name': 'Washington DC Decoy', 'point': LatLng(38.9, -77.0), 'color': Color(0xFF00D4FF)},
    {'name': 'London Decoy', 'point': LatLng(51.5, -0.12), 'color': Color(0xFF00D4FF)},
    {'name': 'Tokyo Decoy', 'point': LatLng(35.68, 139.69), 'color': Color(0xFF00D4FF)},
  ];

  // Attack Vector Line Colors from AttackMap.tsx
  static const List<Color> _lineColors = [
    Color(0xFF00D4FF),
    Color(0xFFFF3366),
    Color(0xFFAA55FF),
    Color(0xFF10B981),
    Color(0xFFFF8800),
  ];

  // Comprehensive Country Geocoordinates Centroid Mapping
  static const Map<String, LatLng> _countryCentroids = {
    'US': LatLng(37.0902, -95.7129),
    'UNITED STATES': LatLng(37.0902, -95.7129),
    'USA': LatLng(37.0902, -95.7129),
    'CN': LatLng(35.8617, 104.1954),
    'CHINA': LatLng(35.8617, 104.1954),
    'RU': LatLng(61.5240, 105.3188),
    'RUSSIA': LatLng(61.5240, 105.3188),
    'DE': LatLng(51.1657, 10.4515),
    'GERMANY': LatLng(51.1657, 10.4515),
    'NL': LatLng(52.1326, 5.2913),
    'NETHERLANDS': LatLng(52.1326, 5.2913),
    'IN': LatLng(20.5937, 78.9629),
    'INDIA': LatLng(20.5937, 78.9629),
    'BR': LatLng(-14.2350, -51.9253),
    'BRAZIL': LatLng(-14.2350, -51.9253),
    'GB': LatLng(55.3781, -3.4360),
    'UNITED KINGDOM': LatLng(55.3781, -3.4360),
    'UK': LatLng(55.3781, -3.4360),
    'FR': LatLng(46.2276, 2.2137),
    'FRANCE': LatLng(46.2276, 2.2137),
    'JP': LatLng(36.2048, 138.2529),
    'JAPAN': LatLng(36.2048, 138.2529),
    'AU': LatLng(-25.2744, 133.7751),
    'AUSTRALIA': LatLng(-25.2744, 133.7751),
    'SG': LatLng(1.3521, 103.8198),
    'SINGAPORE': LatLng(1.3521, 103.8198),
    'KR': LatLng(35.9078, 127.7669),
    'SOUTH KOREA': LatLng(35.9078, 127.7669),
    'CA': LatLng(56.1304, -106.3468),
    'CANADA': LatLng(56.1304, -106.3468),
    'IT': LatLng(41.8719, 12.5674),
    'ITALY': LatLng(41.8719, 12.5674),
    'ES': LatLng(40.4637, -3.7492),
    'SPAIN': LatLng(40.4637, -3.7492),
    'UA': LatLng(48.3794, 31.1656),
    'UKRAINE': LatLng(48.3794, 31.1656),
    'ZA': LatLng(-30.5595, 22.9375),
    'SOUTH AFRICA': LatLng(-30.5595, 22.9375),
    'VN': LatLng(14.0583, 108.2772),
    'VIETNAM': LatLng(14.0583, 108.2772),
    'ID': LatLng(-0.7893, 113.9213),
    'INDONESIA': LatLng(-0.7893, 113.9213),
    'SE': LatLng(60.1282, 18.6435),
    'SWEDEN': LatLng(60.1282, 18.6435),
    'PL': LatLng(51.9194, 19.1451),
    'POLAND': LatLng(51.9194, 19.1451),
    'TR': LatLng(38.9637, 35.2433),
    'TURKEY': LatLng(38.9637, 35.2433),
    'MX': LatLng(23.6345, -102.5528),
    'MEXICO': LatLng(23.6345, -102.5528),
    'AR': LatLng(-38.4161, -63.6167),
    'ARGENTINA': LatLng(-38.4161, -63.6167),
    'EG': LatLng(26.8206, 30.8025),
    'EGYPT': LatLng(26.8206, 30.8025),
    'SA': LatLng(23.8859, 45.0792),
    'SAUDI ARABIA': LatLng(23.8859, 45.0792),
    'AE': LatLng(23.4241, 53.8478),
    'UNITED ARAB EMIRATES': LatLng(23.4241, 53.8478),
    'IL': LatLng(31.0461, 34.8516),
    'ISRAEL': LatLng(31.0461, 34.8516),
    'PK': LatLng(30.3753, 69.3451),
    'PAKISTAN': LatLng(30.3753, 69.3451),
    'BD': LatLng(23.6850, 90.3563),
    'BANGLADESH': LatLng(23.6850, 90.3563),
    'IR': LatLng(32.4279, 53.6880),
    'IRAN': LatLng(32.4279, 53.6880),
    'TH': LatLng(15.8700, 100.9925),
    'THAILAND': LatLng(15.8700, 100.9925),
    'MY': LatLng(4.2105, 101.9758),
    'MALAYSIA': LatLng(4.2105, 101.9758),
    'PH': LatLng(12.8797, 121.7740),
    'PHILIPPINES': LatLng(12.8797, 121.7740),
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _arcAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      final res = await ref.read(apiClientProvider).getGeoLocation();
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final lat = data['latitude'] ?? data['lat'];
        final lng = data['longitude'] ?? data['lng'] ?? data['lon'];
        final city = data['city'] ?? data['regionName'] ?? data['country'];
        if (lat != null && lng != null) {
          final resolved = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );
          if (mounted) {
            setState(() {
              _userLocation = resolved;
              _userCity = city?.toString();
            });
            _mapController.move(resolved, 2.5);
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userLocation = const LatLng(20.5937, 78.9629);
          _userCity = 'India';
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arcAnimController.dispose();
    _dynamicAttackTimer?.cancel();
    super.dispose();
  }

  LatLng _getOriginCoords(SecurityEvent event, int index) {
    if (event.lat != null && event.lng != null) {
      return LatLng(event.lat!, event.lng!);
    }

    final countryKey = event.countryCode.isNotEmpty
        ? event.countryCode.toUpperCase()
        : event.country.toUpperCase();

    if (_countryCentroids.containsKey(countryKey)) {
      final base = _countryCentroids[countryKey]!;
      final offsetLat = (sin(index * 1.5) * 1.5);
      final offsetLng = (cos(index * 1.5) * 2.2);
      return LatLng(base.latitude + offsetLat, base.longitude + offsetLng);
    }

    // If local network or user's subnet, map to the user's actual location!
    if (event.country.toLowerCase().contains('local') ||
        event.sourceIp.startsWith('10.') ||
        event.sourceIp.startsWith('192.168.') ||
        event.sourceIp.startsWith('127.')) {
      final base = _userLocation ?? const LatLng(20.5937, 78.9629);
      final offsetLat = (sin(index * 1.2) * 0.8);
      final offsetLng = (cos(index * 1.2) * 1.0);
      return LatLng(base.latitude + offsetLat, base.longitude + offsetLng);
    }

    // Deterministic hash fallback
    final hash = event.sourceIp.hashCode.abs();
    return LatLng(10.0 + (hash % 45), -110.0 + (hash % 220));
  }

  List<LatLng> _generateBallisticArc(LatLng p1, LatLng p2) {
    final points = <LatLng>[];
    const steps = 14;
    final dLat = p2.latitude - p1.latitude;
    final dLng = p2.longitude - p1.longitude;
    final dist = sqrt(dLat * dLat + dLng * dLng);
    final arcHeight = min(22.0, max(5.0, dist * 0.18));

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = p1.latitude + (dLat * t) + (sin(t * pi) * arcHeight);
      final lng = p1.longitude + (dLng * t);
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  String _getTileUrlTemplate() {
    switch (_tileStyle) {
      case ThreatMapTileStyle.darkCyber:
        return 'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}';
      case ThreatMapTileStyle.openStreetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case ThreatMapTileStyle.cartoVoyager:
        return 'https://a.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = widget.events.where((e) {
      if (widget.selectedProtocol == 'ALL') return true;
      return e.protocol.toUpperCase() == widget.selectedProtocol.toUpperCase();
    }).toList();

    // 1. Build Multi-Colored Attack Trajectories
    final polylines = <Polyline>[];
    for (int i = 0; i < filteredEvents.length; i++) {
      final e = filteredEvents[i];
      final origin = _getOriginCoords(e, i);
      final targetHoneypot = _honeypots[i % _honeypots.length]['point'] as LatLng;
      final color = _lineColors[i % _lineColors.length];

      final arcPoints = _generateBallisticArc(origin, targetHoneypot);

      polylines.add(
        Polyline(
          points: arcPoints,
          strokeWidth: 2.2,
          color: color.withValues(alpha: 0.85),
          pattern: StrokePattern.dashed(segments: const [6.0, 4.0]),
        ),
      );
    }

    // 2. Build Markers (Honeypots + User Location + Attacker Origins + Backend Stats Origins)
    final markers = <Marker>[];

    // Honeypot Decoys (Cyan Nodes)
    for (final hp in _honeypots) {
      final pt = hp['point'] as LatLng;
      final color = hp['color'] as Color;
      final name = hp['name'] as String;

      markers.add(
        Marker(
          point: pt,
          width: 36,
          height: 36,
          child: Tooltip(
            message: name,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.4);
                final alpha = max(0.0, 1.0 - _pulseController.value);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withValues(alpha: alpha), width: 1.5),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.shield, color: Colors.black, size: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    // User Location / Client Ingress (Emerald Green Beacon)
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 40,
          height: 40,
          child: Tooltip(
            message: 'Your Location (${_userCity ?? "Connected"})',
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.5);
                final alpha = max(0.0, 1.0 - _pulseController.value);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: alpha), width: 2),
                        ),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF10B981), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.my_location, color: Colors.black, size: 11),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    // Backend Origins from Stats (if provided)
    if (widget.origins != null) {
      for (final o in widget.origins!) {
        if (o.lat != null && o.lng != null) {
          final pt = LatLng(o.lat!, o.lng!);
          final radius = min(max(o.count / 25.0 + 8.0, 10.0), 22.0);

          markers.add(
            Marker(
              point: pt,
              width: radius * 2,
              height: radius * 2,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedOrigin = o);
                },
                child: Center(
                  child: Container(
                    width: radius,
                    height: radius,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3366).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFFF3366), blurRadius: 8, spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    // Live Security Event Attacker Origins (Red Blips)
    for (int i = 0; i < filteredEvents.length; i++) {
      final e = filteredEvents[i];
      final pt = _getOriginCoords(e, i);

      markers.add(
        Marker(
          point: pt,
          width: 28,
          height: 28,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedEvent = e);
              if (widget.onSelectEvent != null) {
                widget.onSelectEvent!(e);
              }
            },
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3366),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFF3366), blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFF060B14),
        child: Stack(
          children: [
            // Layer 1: Real Active Leaflet Tile Engine
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? const LatLng(20.5937, 78.9629),
                initialZoom: widget.isInteractive ? 2.2 : 1.3,
                minZoom: 1.0,
                maxZoom: 18.0,
                interactionOptions: InteractionOptions(
                  flags: widget.isInteractive ? InteractiveFlag.all : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  key: ValueKey(_tileStyle),
                  urlTemplate: _getTileUrlTemplate(),
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.leukquant.app.leukquant_mobile',
                  maxZoom: 18,
                ),

                // Attack Trajectories
                PolylineLayer(polylines: polylines),

                // Honeypots & Attacker Markers
                MarkerLayer(markers: markers),
              ],
            ),

            // Cyber Decorative Corners (┌ ┐ └ ┘)
            Positioned(top: 6, left: 6, child: _buildCorner(top: true, left: true)),
            Positioned(top: 6, right: 6, child: _buildCorner(top: true, left: false)),
            Positioned(bottom: 6, left: 6, child: _buildCorner(top: false, left: true)),
            Positioned(bottom: 6, right: 6, child: _buildCorner(top: false, left: false)),

            // HUD Info Header (Matching Web AttackMap.tsx - Zero Overflow)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xEB060B14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _userLocation != null ? 'GLOBAL THREAT MONITOR - TARGET LOCK' : 'GLOBAL THREAT MONITOR',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00D4FF),
                                fontFamily: 'monospace',
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${filteredEvents.length} ATTACKS',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map Legend / Key Panel
            if (_showLegend) ...[
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xEB070D18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('MAP KEY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, fontFamily: 'monospace')),
                      const SizedBox(height: 6),
                      _buildLegendItem(const Color(0xFFFF3366), 'Attack Origin'),
                      const SizedBox(height: 4),
                      _buildLegendItem(const Color(0xFF00D4FF), 'Honeypot Decoy'),
                      const SizedBox(height: 4),
                      _buildLegendItem(const Color(0xFF10B981), 'Your Location'),
                      const SizedBox(height: 4),
                      _buildLegendItem(const Color(0xFFAA55FF), 'Attack Vector'),
                    ],
                  ),
                ),
              ),
            ],

            // Map Controls
            if (widget.isInteractive) ...[
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Layer Style Switcher
                    _buildControlBtn(Icons.layers_rounded, () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_tileStyle == ThreatMapTileStyle.darkCyber) {
                          _tileStyle = ThreatMapTileStyle.openStreetMap;
                        } else if (_tileStyle == ThreatMapTileStyle.openStreetMap) {
                          _tileStyle = ThreatMapTileStyle.cartoVoyager;
                        } else {
                          _tileStyle = ThreatMapTileStyle.darkCyber;
                        }
                      });
                    }),
                    const SizedBox(height: 5),
                    _buildControlBtn(Icons.info_outline_rounded, () {
                      HapticFeedback.selectionClick();
                      setState(() => _showLegend = !_showLegend);
                    }),
                    const SizedBox(height: 5),
                    _buildControlBtn(Icons.my_location_rounded, () {
                      HapticFeedback.lightImpact();
                      if (_userLocation != null) {
                        _mapController.move(_userLocation!, 3.2);
                      }
                    }),
                    const SizedBox(height: 5),
                    _buildControlBtn(Icons.add_rounded, () {
                      HapticFeedback.lightImpact();
                      _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 0.6);
                    }),
                    const SizedBox(height: 5),
                    _buildControlBtn(Icons.remove_rounded, () {
                      HapticFeedback.lightImpact();
                      _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 0.6);
                    }),
                  ],
                ),
              ),
            ],

            // Selected Origin / Event Forensic HUD
            if (_selectedEvent != null || _selectedOrigin != null) ...[
              Positioned(
                left: 12,
                bottom: 12,
                right: widget.isInteractive ? 50 : 12,
                child: GestureDetector(
                  onTap: () {
                    if (_selectedEvent != null) {
                      EventDetailsSheet.show(context, _selectedEvent!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xF2070D18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00D4FF), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: Color(0xFFFF3366), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedEvent != null
                                ? '${_selectedEvent!.sourceIp} (${_selectedEvent!.country}) → ${_selectedEvent!.honeypot}'
                                : '${_selectedOrigin!.country} (${_selectedOrigin!.count} Attacks Intercepted)',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedEvent = null;
                            _selectedOrigin = null;
                          }),
                          child: const Icon(Icons.close_rounded, size: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Color(0xFF00D4FF), width: 1.5) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0xFF00D4FF), width: 1.5) : BorderSide.none,
          left: left ? const BorderSide(color: Color(0xFF00D4FF), width: 1.5) : BorderSide.none,
          right: !left ? const BorderSide(color: Color(0xFF00D4FF), width: 1.5) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF), fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: const Color(0xFF00D4FF), size: 15),
      ),
    );
  }
}
