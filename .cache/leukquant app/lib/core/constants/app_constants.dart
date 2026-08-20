/// Application-wide constants for LeukQuant Mobile.
class AppConstants {
  AppConstants._();

  static const String appName = 'LeukQuant Mobile';
  static const String appSubtitle = 'Security Monitoring';
  static const String appVersion = 'v1.0.0 (Build 101)';
  static const String copyright = '© 2026 LeukQuant Security. All rights reserved.';

  // Storage keys
  static const String themeModeKey = 'leukquant_theme_mode';
  static const String inAppAlertsKey = 'leukquant_in_app_alerts';
  static const String demoModeKey = 'leukquant_demo_mode';
  static const String onboardingCompletedKey = 'leukquant_onboarding_completed';

  // Status Strings
  static const String awaitingBackendData = 'Awaiting backend data';
  static const String awaitingOrgData = 'Awaiting organisation data';
  static const String awaitingProfileData = 'Awaiting profile data';
  static const String pushServicePending = 'Backend push service pending';
  static const String reportServicePending = 'Backend report generation service pending';
  static const String noEventsState = 'No events received. Awaiting backend stream.';
  static const String noIncidentsState = 'No incidents detected. Awaiting backend analysis.';
  static const String exportDisabledNotice = 'Report export will be enabled when connected to the backend reporting engine.';
  static const String chartEmptyTrend = 'Activity trend will appear after telemetry is connected.';
  static const String chartEmptyThreat = 'Threat categories will populate once telemetry is classified.';
  static const String chartEmptyProtocol = 'Protocol breakdown will display once active traffic is monitored.';
}
