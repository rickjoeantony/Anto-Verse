// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/events/domain/security_event.dart';

/// Service managing real-time Android push & local notifications for threat telemetry.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // In-app navigation payload handling
      },
    );

    // Request notification permission on Android 13+ (API 33+)
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();

      const channel = AndroidNotificationChannel(
        'leukquant_security_alerts',
        'Security Incident Alerts',
        description: 'Real-time alerts when honeypot sensors or decoy traps detect attack vectors',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }

  /// Trigger rich mobile notification when an attack is logged
  Future<void> showAttackNotification(SecurityEvent event) async {
    try {
      final int notifId = event.id.hashCode & 0x7fffffff;

      final typeStr = _formatEventType(event.type.isNotEmpty ? event.type : event.classification);
      final title = '🚨 Alert: $typeStr';
      final portStr = event.destinationPort.isNotEmpty ? event.destinationPort : (event.protocol.isNotEmpty ? event.protocol : '22');
      final body = 'Attacker IP: ${event.sourceIp} (${event.country.isNotEmpty ? event.country : "Unknown"}) • Port/Proto: $portStr • Severity: ${event.severity.name.toUpperCase()}';

      const androidDetails = AndroidNotificationDetails(
        'leukquant_security_alerts',
        'Security Incident Alerts',
        channelDescription: 'Real-time alerts when honeypot sensors or decoy traps detect attack vectors',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Security Alert Detected',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const notifDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(
        notifId,
        title,
        body,
        notifDetails,
        payload: event.id,
      );
    } catch (_) {
      // Safe fallback
    }
  }

  String _formatEventType(String raw) {
    final lower = raw.toLowerCase().trim();
    switch (lower) {
      case 'ddos':
        return 'DDoS Attack';
      case 'credential_stuffing':
        return 'Credential Stuffing';
      case 'brute_force':
        return 'Brute Force SSH';
      case 'injection':
      case 'sqli':
        return 'SQL Injection';
      case 'xss':
        return 'XSS Attack';
      case 'ssh':
        return 'SSH Decoy Ingress';
      case 'rdp':
        return 'RDP Probe';
      case 'ftp':
        return 'FTP Access Attempt';
      case 'dns':
        return 'DNS Tunneling Attempt';
      default:
        return raw.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
  }
}
