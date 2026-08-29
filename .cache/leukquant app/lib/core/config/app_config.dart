// lib/core/config/app_config.dart

import 'package:flutter/foundation.dart';

/// Compile-time configuration for LeukQuant Mobile.
///
/// RULES:
/// - Base URLs are injected via `--dart-define` and NEVER hardcoded as staging/production defaults.
/// - Default values are strictly empty strings.
/// - APP_ENV defaults to empty string:
///   * In debug builds without flag -> 'local'
///   * In release builds without flag -> 'production'
///   * Explicit APP_ENV flag always wins.
/// - In local mode: HTTP/ws:// allowed for development targets.
/// - In staging mode: require https/wss staging URLs.
/// - In production mode: require https/wss production URLs, never allow cleartext HTTP or localhost/LAN/link-local IPs.
class AppConfig {
  AppConfig._();

  /// REST API Base URL injected via --dart-define=API_BASE_URL=...
  /// Defaults to empty string to prevent accidental connections in development builds.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// WebSocket Stream Base URL injected via --dart-define=WS_BASE_URL=...
  /// Defaults to empty string to prevent accidental connections in development builds.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  /// Explicit environment string injected via --dart-define=APP_ENV=...
  /// Defaults to empty string to prevent accidental local mode in release builds.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: '',
  );

  /// Effective environment considering build mode:
  /// - Explicit APP_ENV flag always wins if provided.
  /// - In Release mode (kReleaseMode), defaults to 'production'.
  /// - In Debug/Profile mode, defaults to 'local'.
  static String get effectiveEnv {
    if (appEnv.trim().isNotEmpty) {
      return appEnv.trim().toLowerCase();
    }
    return kReleaseMode ? 'production' : 'local';
  }

  /// Notice displayed when backend connection has not been provided via dart-define.
  static const String notConfiguredNotice = 'Backend connection not configured.';

  /// Environment helpers
  static bool get isLocal => effectiveEnv == 'local' || effectiveEnv == 'development';
  static bool get isStaging => effectiveEnv == 'staging';
  static bool get isProduction => effectiveEnv == 'production' || effectiveEnv == 'prod';

  /// Validates whether the configured URL is secure and compliant with the active environment.
  static String? validateUrl(String url, {String? env, bool isWs = false}) {
    if (url.trim().isEmpty) {
      return notConfiguredNotice;
    }

    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Invalid URL format: $url';
    }

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    final targetEnv = (env ?? effectiveEnv).toLowerCase();

    if (targetEnv == 'production' || targetEnv == 'prod') {
      final expectedScheme = isWs ? 'wss' : 'https';
      if (scheme != expectedScheme) {
        return 'Production requires secure $expectedScheme:// protocol. Got: $scheme://';
      }

      // Check for forbidden localhost, private LAN, link-local, or *.local addresses in production
      if (_isPrivateOrLocalHost(host)) {
        return 'Production environment cannot use local, private, or link-local host ($host).';
      }
    } else if (targetEnv == 'staging') {
      final expectedScheme = isWs ? 'wss' : 'https';
      if (scheme != expectedScheme) {
        return 'Staging requires secure $expectedScheme:// protocol. Got: $scheme://';
      }
    } else {
      // Local mode allows http, https, ws, wss
      final allowedSchemes = isWs ? ['ws', 'wss'] : ['http', 'https'];
      if (!allowedSchemes.contains(scheme)) {
        return 'Invalid scheme $scheme for $targetEnv environment.';
      }
    }

    return null;
  }

  /// Checks if host is localhost, loopback, private IPv4, link-local IPv4, or *.local mDNS domain.
  static bool _isPrivateOrLocalHost(String host) {
    // Exact hostname matches
    if (host == 'localhost' ||
        host == '10.0.2.2' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1') {
      return true;
    }

    // Loopback IPv4 range: 127.0.0.0/8
    if (host.startsWith('127.') || RegExp(r'^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // mDNS / Local domain (*.local)
    if (host.endsWith('.local') || host == 'local') {
      return true;
    }

    // Link-local IPv4 range: 169.254.0.0/16
    if (host.startsWith('169.254.')) {
      return true;
    }

    // 10.0.0.0/8
    if (host.startsWith('10.') || RegExp(r'^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // 192.168.0.0/16
    if (host.startsWith('192.168.') || RegExp(r'^192\.168\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // 172.16.0.0/12 (172.16.0.0 - 172.31.255.255)
    final match172 = RegExp(r'^172\.(\d{1,3})\.').firstMatch(host);
    if (match172 != null) {
      final secondOctet = int.tryParse(match172.group(1) ?? '');
      if (secondOctet != null && secondOctet >= 16 && secondOctet <= 31) {
        return true;
      }
    }

    return false;
  }

  /// Whether the backend connection has been configured and is valid for the current environment.
  static bool get isConfigured {
    if (apiBaseUrl.trim().isEmpty) return false;
    final validationError = validateUrl(apiBaseUrl, isWs: false);
    return validationError == null;
  }

  /// Returns the configuration error reason if invalid, or null if properly configured.
  static String? get configurationError {
    if (apiBaseUrl.trim().isEmpty) return notConfiguredNotice;
    return validateUrl(apiBaseUrl, isWs: false);
  }

  /// Safe Hostname extractor: returns only hostname and port, NEVER query params or tokens.
  static String get apiHost {
    if (apiBaseUrl.isEmpty) return 'Not configured';
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || uri.host.isEmpty) return 'Invalid URL';
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      return '${uri.host}:${uri.port}';
    }
    return uri.host;
  }

  /// Safe WebSocket Hostname extractor
  static String get wsHost {
    if (wsBaseUrl.isEmpty) return 'Not configured';
    final uri = Uri.tryParse(wsBaseUrl);
    if (uri == null || uri.host.isEmpty) return 'Invalid URL';
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      return '${uri.host}:${uri.port}';
    }
    return uri.host;
  }
}
