// lib/core/config/app_config.dart

/// Compile-time configuration for LeukQuant Mobile.
/// Base URLs are injected via --dart-define and NEVER hardcoded as staging/production defaults.
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

  /// Runtime environment name (development, staging, production)
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Whether the backend connection has been configured via dart-define.
  static bool get isConfigured => apiBaseUrl.isNotEmpty;

  /// Notice displayed when backend connection has not been provided via dart-define.
  static const String notConfiguredNotice = 'Backend connection not configured.';
}
