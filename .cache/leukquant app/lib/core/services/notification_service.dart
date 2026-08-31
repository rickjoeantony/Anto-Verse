// lib/core/services/notification_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/events/domain/security_event.dart';
import '../../features/events/domain/severity_level.dart';

/// Service managing real-time cross-platform (Android & iOS) push & local notifications
/// with loud audio alert chimes, lockscreen banners, and background wake capabilities.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const MethodChannel _nativeChannel = MethodChannel('com.leukquant.app/audio_alerts');
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _criticalChannelId = 'leukquant_critical_telemetry_v11';
  static const String _criticalChannelName = '🚨 Critical & High Security Alerts';
  static const String _criticalChannelDescription =
      'Real-time loud alerts for Critical and High risk intrusion attempts that wake the lock screen.';

  static const String _mediumChannelId = 'leukquant_medium_telemetry_v11';
  static const String _mediumChannelName = '🔶 Medium Risk Security Alerts';
  static const String _mediumChannelDescription =
      'Immediate notifications for Medium risk intrusion events, honeypot probes, and decoy touches.';

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Navigation or deep linking when notification is clicked
        },
      );

      // Android Notification Channels Configuration
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();

        final criticalVibration = Int64List.fromList([0, 500, 200, 500, 200, 500]);
        final criticalChannel = AndroidNotificationChannel(
          _criticalChannelId,
          _criticalChannelName,
          description: _criticalChannelDescription,
          importance: Importance.max,
          enableVibration: true,
          vibrationPattern: criticalVibration,
          playSound: true,
          enableLights: true,
          showBadge: true,
        );

        final mediumVibration = Int64List.fromList([0, 300, 150, 300]);
        final mediumChannel = AndroidNotificationChannel(
          _mediumChannelId,
          _mediumChannelName,
          description: _mediumChannelDescription,
          importance: Importance.high,
          enableVibration: true,
          vibrationPattern: mediumVibration,
          playSound: true,
          enableLights: true,
          showBadge: true,
        );

        await androidImpl.createNotificationChannel(criticalChannel);
        await androidImpl.createNotificationChannel(mediumChannel);
      }

      // iOS Permission Request
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }

    _isInitialized = true;
  }

  /// Play audible alert sound via native audio bridge or platform fallback
  Future<void> playTone(String type) async {
    try {
      await _nativeChannel.invokeMethod('playAlertTone', {'type': type});
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.alert);
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Trigger real-time mobile notification when an attack is logged
  /// Optimized for Medium, High, and Critical Risk attacks on locked screens & closed apps.
  Future<void> showAttackNotification(SecurityEvent event) async {
    try {
      final int notifId = event.id.hashCode & 0x7fffffff;
      final typeStr = _formatEventType(event.type.isNotEmpty ? event.type : event.classification);
      final portStr = event.destinationPort.isNotEmpty
          ? event.destinationPort
          : (event.protocol.isNotEmpty ? event.protocol : '22');

      final bool isCritical = event.severity == SeverityLevel.critical || event.threatLevel >= 4;
      final bool isHigh = event.severity == SeverityLevel.high || event.threatLevel == 3;
      final bool isMedium = event.severity == SeverityLevel.warning || event.threatLevel == 2;

      String title;
      String toneType;
      String channelId;
      String channelName;
      String channelDesc;

      if (isCritical) {
        title = '🚨 CRITICAL ATTACK: $typeStr Ingress';
        toneType = 'cyberRadar';
        channelId = _criticalChannelId;
        channelName = _criticalChannelName;
        channelDesc = _criticalChannelDescription;
      } else if (isHigh) {
        title = '⚠️ HIGH-RISK ALERT: $typeStr Detected';
        toneType = 'tacticalPulse';
        channelId = _criticalChannelId;
        channelName = _criticalChannelName;
        channelDesc = _criticalChannelDescription;
      } else if (isMedium) {
        title = '🔶 MEDIUM-RISK: $typeStr Logged';
        toneType = 'enterprisePing';
        channelId = _mediumChannelId;
        channelName = _mediumChannelName;
        channelDesc = _mediumChannelDescription;
      } else {
        title = '🛡️ LeukQuant Alert: $typeStr';
        toneType = 'enterprisePing';
        channelId = _mediumChannelId;
        channelName = _mediumChannelName;
        channelDesc = _mediumChannelDescription;
      }

      final body =
          'Source IP: ${event.sourceIp} (${event.country.isNotEmpty ? event.country : "Unknown"}) · Port: $portStr · Severity: ${event.severity.displayName.toUpperCase()}';

      // 1. Try native platform bridge (handles screen wakeup and alarm stream)
      try {
        await _nativeChannel.invokeMethod('postAlertNotification', {
          'id': notifId,
          'title': title,
          'body': body,
          'severity': event.severity.name,
          'isCritical': isCritical || isHigh,
        });
        return;
      } catch (_) {}

      // 2. Fallback via FlutterLocalNotificationsPlugin with Lock-Screen & Background setup
      if (!_isInitialized) await init();

      final vibrationPattern = isCritical || isHigh
          ? Int64List.fromList([0, 500, 200, 500, 200, 500])
          : Int64List.fromList([0, 300, 150, 300]);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: isCritical || isHigh ? Importance.max : Importance.high,
        priority: isCritical || isHigh ? Priority.max : Priority.high,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        ticker: title,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        enableLights: true,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'LeukQuant SOC Security Alert',
        ),
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: (isCritical || isHigh)
            ? InterruptionLevel.critical
            : InterruptionLevel.timeSensitive,
        subtitle: isCritical ? 'CRITICAL SOC ALERT' : (isHigh ? 'HIGH RISK ALERT' : 'MEDIUM RISK ALERT'),
      );

      await _plugin.show(
        notifId,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        payload: event.id,
      );

      await playTone(toneType);
    } catch (e) {
      debugPrint('[NotificationService] Show attack notification error: $e');
    }
  }

  /// Trigger a live test alert with full sound, vibration, and system tray banner
  Future<void> sendTestNotification([String toneType = 'cyberRadar']) async {
    try {
      const title = '⚡ Test Alert: SSH Decoy Ingress';
      const body = 'Target: SSH Decoy (Port 22) • Attacker IP: 192.168.1.105 (US) • Action: Isolated & Logged';

      // 1. Dispatch via native bridge
      try {
        await _nativeChannel.invokeMethod('postAlertNotification', {
          'id': 88888,
          'title': title,
          'body': body,
          'severity': 'high',
          'isCritical': true,
        });
        return;
      } catch (_) {}

      // 2. Fallback via FlutterLocalNotificationsPlugin
      if (!_isInitialized) await init();

      final vibrationPattern = Int64List.fromList([0, 500, 200, 500, 200, 500]);
      final androidDetails = AndroidNotificationDetails(
        _criticalChannelId,
        _criticalChannelName,
        channelDescription: _criticalChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        ticker: 'Test Security Alert',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
        enableLights: true,
        channelShowBadge: true,
        styleInformation: const BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'LeukQuant Telemetry Live',
        ),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        subtitle: 'Test Security Alert',
      );

      await _plugin.show(
        88888,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        payload: 'test_alert',
      );

      await playTone(toneType);
    } catch (e) {
      debugPrint('[NotificationService] Send test notification error: $e');
    }
  }

  /// Open Android OS System Notification settings for LeukQuant
  Future<void> openNotificationSettings() async {
    try {
      await _nativeChannel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('[NotificationService] openNotificationSettings error: $e');
    }
  }

  /// Open Android OS Battery Optimization settings for LeukQuant (to allow background execution)
  Future<void> openBatterySettings() async {
    try {
      await _nativeChannel.invokeMethod('openBatterySettings');
    } catch (e) {
      debugPrint('[NotificationService] openBatterySettings error: $e');
    }
  }

  /// Open Android OS Full Screen Notification / Display over apps settings
  Future<void> openFullScreenSettings() async {
    try {
      await _nativeChannel.invokeMethod('openFullScreenSettings');
    } catch (e) {
      debugPrint('[NotificationService] openFullScreenSettings error: $e');
    }
  }

  /// Check if battery optimization has been disabled / unrestricted
  Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final bool? result = await _nativeChannel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return result ?? false;
    } catch (_) {
      return false;
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