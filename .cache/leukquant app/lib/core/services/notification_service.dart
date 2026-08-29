// lib/core/services/notification_service.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/events/domain/security_event.dart';

/// Service managing real-time Android system push & local notifications with audio alert chimes.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _channelId = 'leukquant_threat_telemetry_v3';
  static const String _channelName = 'Critical Security Alerts';
  static const String _channelDescription =
      'Real-time audible alerts when honeypot sensors or decoy traps detect unauthorized ingress.';

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // In-app deep link or navigation
      },
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // 1. Explicitly request runtime POST_NOTIFICATIONS permission for Android 13+ / 16
      await androidImpl.requestNotificationsPermission();

      // 2. Register high-priority notification channel with audio sound and tactile vibration
      final vibrationPattern = Int64List.fromList([0, 300, 150, 300]);
      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        enableLights: true,
        showBadge: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }

  /// Request runtime permission explicitly
  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Trigger real-time mobile notification when an attack is logged
  Future<void> showAttackNotification(SecurityEvent event) async {
    try {
      if (!_isInitialized) await init();

      final int notifId = event.id.hashCode & 0x7fffffff;
      final typeStr = _formatEventType(event.type.isNotEmpty ? event.type : event.classification);
      final title = 'ðŸš¨ Alert: $typeStr';
      final portStr = event.destinationPort.isNotEmpty ? event.destinationPort : (event.protocol.isNotEmpty ? event.protocol : '22');
      final body = 'Attacker IP: ${event.sourceIp} (${event.country.isNotEmpty ? event.country : "Unknown"}) â€¢ Port/Proto: $portStr â€¢ Severity: ${event.severity.name.toUpperCase()}';

      final vibrationPattern = Int64List.fromList([0, 300, 150, 300]);
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Critical Attack Logged',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        enableLights: true,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'LeukQuant Autonomous SOC',
        ),
      );

      final notifDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(
        notifId,
        title,
        body,
        notifDetails,
        payload: event.id,
      );

      // Also trigger system audio feedback
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Graceful fallback
    }
  }

  /// Trigger a live test alert with full sound, vibration, and system tray banner
  Future<void> sendTestNotification() async {
    try {
      if (!_isInitialized) await init();

      final vibrationPattern = Int64List.fromList([0, 350, 150, 350]);
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Test Security Alert',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        enableLights: true,
        channelShowBadge: true,
        styleInformation: const BigTextStyleInformation(
          'Target: SSH Decoy (Port 22) â€¢ Attacker IP: 192.168.1.105 (US) â€¢ Action: Isolated & Logged',
          contentTitle: 'ðŸš¨ Test Alert: SSH Decoy Ingress',
          summaryText: 'LeukQuant Telemetry Live',
        ),
      );

      final notifDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(
        88888,
        'ðŸš¨ Test Alert: SSH Decoy Ingress',
        'Target: SSH Decoy (Port 22) â€¢ Attacker IP: 192.168.1.105 (US) â€¢ Action: Isolated & Logged',
        notifDetails,
        payload: 'test_alert',
      );

      // Play system alert sound & heavy haptic feedback
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Graceful fallback
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