// lib/features/diagnostics/presentation/diagnostics_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../auth/providers/auth_state_provider.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _isRunningCheck = false;
  bool? _healthReachable;
  int? _healthStatusCode;
  String? _healthLatencyBucket;
  bool? _configReachable;
  int? _configStatusCode;
  String? _configLatencyBucket;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runDiagnostics();
    });
  }

  String _formatLatency(int elapsedMs) {
    if (elapsedMs < 50) return '< 50ms (Optimal)';
    if (elapsedMs <= 150) return '50–150ms (Normal)';
    if (elapsedMs <= 300) return '150–300ms (Moderate)';
    return '> 300ms (High Latency)';
  }

  Future<void> _runDiagnostics() async {
    if (_isRunningCheck) return;

    setState(() {
      _isRunningCheck = true;
      _errorMessage = null;
    });

    if (!AppConfig.isConfigured) {
      setState(() {
        _isRunningCheck = false;
        _healthReachable = false;
        _healthStatusCode = null;
        _healthLatencyBucket = null;
        _configReachable = false;
        _configStatusCode = null;
        _configLatencyBucket = null;
        _errorMessage = AppConfig.configurationError ?? AppConfig.notConfiguredNotice;
      });
      return;
    }

    final apiClient = ref.read(apiClientProvider);

    // Diagnostic Call 1: GET /api/health
    final stopwatchHealth = Stopwatch()..start();
    try {
      final res = await apiClient.getHealth().timeout(const Duration(seconds: 5));
      stopwatchHealth.stop();
      if (mounted) {
        setState(() {
          _healthReachable = true;
          _healthStatusCode = res.statusCode ?? 200;
          _healthLatencyBucket = _formatLatency(stopwatchHealth.elapsedMilliseconds);
        });
      }
    } on TimeoutException {
      stopwatchHealth.stop();
      if (mounted) {
        setState(() {
          _healthReachable = false;
          _healthStatusCode = null;
          _healthLatencyBucket = 'Timeout (> 5s)';
        });
      }
    } catch (e) {
      stopwatchHealth.stop();
      if (mounted) {
        setState(() {
          _healthReachable = false;
          _healthStatusCode = null;
          _healthLatencyBucket = 'Failed / Unreachable';
        });
      }
    }

    // Diagnostic Call 2: GET /api/config
    final stopwatchConfig = Stopwatch()..start();
    try {
      final res = await apiClient.getConfig().timeout(const Duration(seconds: 5));
      stopwatchConfig.stop();
      if (mounted) {
        setState(() {
          _configReachable = true;
          _configStatusCode = res.statusCode ?? 200;
          _configLatencyBucket = _formatLatency(stopwatchConfig.elapsedMilliseconds);
        });
      }
    } on TimeoutException {
      stopwatchConfig.stop();
      if (mounted) {
        setState(() {
          _configReachable = false;
          _configStatusCode = null;
          _configLatencyBucket = 'Timeout (> 5s)';
        });
      }
    } catch (e) {
      stopwatchConfig.stop();
      if (mounted) {
        setState(() {
          _configReachable = false;
          _configStatusCode = null;
          _configLatencyBucket = 'Failed / Unreachable';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isRunningCheck = false;
      });
    }
  }

  String _generateSanitizedReport(WidgetRef ref) {
    final authState = ref.read(authProvider);
    final wsState = ref.read(webSocketProvider);
    final isNetwork = ref.read(isNetworkAvailableProvider);

    final buffer = StringBuffer();
    buffer.writeln('=== LeukQuant Connection Diagnostics ===');
    buffer.writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln('Environment: ${AppConfig.effectiveEnv}');
    buffer.writeln('Configured: ${AppConfig.isConfigured ? "Yes" : "No"}');
    buffer.writeln('API Host: ${AppConfig.apiHost}');
    buffer.writeln('WS Host: ${AppConfig.wsHost}');
    buffer.writeln('Physical Network: ${isNetwork ? "Available" : "Unavailable"}');
    buffer.writeln('Health Endpoint (/api/health): ${_healthReachable == true ? "Reachable (HTTP $_healthStatusCode, $_healthLatencyBucket)" : (_healthLatencyBucket ?? "Unreachable")}');
    buffer.writeln('Config Endpoint (/api/config): ${_configReachable == true ? "Reachable (HTTP $_configStatusCode, $_configLatencyBucket)" : (_configLatencyBucket ?? "Unreachable")}');
    buffer.writeln('WebSocket State: ${wsState.name}');
    buffer.writeln('Session State: ${authState.isAuthenticated ? "Authenticated" : (authState.isSessionExpired ? "Expired" : "Unauthenticated")}');
    buffer.writeln('========================================');
    return buffer.toString();
  }

  void _copySanitizedReport() {
    final report = _generateSanitizedReport(ref);
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sanitized diagnostics copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final wsState = ref.watch(webSocketProvider);
    final isNetwork = ref.watch(isNetworkAvailableProvider);
    final appConnState = ref.watch(appConnectionStateProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Connection Diagnostics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: colors.brandPrimary, size: 20),
            tooltip: 'Copy Sanitized Report',
            onPressed: _copySanitizedReport,
          ),
          IconButton(
            icon: _isRunningCheck
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.brandPrimary),
                  )
                : Icon(Icons.refresh_rounded, color: colors.brandPrimary, size: 22),
            tooltip: 'Run Health Check',
            onPressed: _isRunningCheck ? null : _runDiagnostics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          children: [
            // Status Banner
            _buildOverallStatusBanner(appConnState, colors),
            const SizedBox(height: 16),

            // Environment & Host info
            _buildSectionHeader('ENVIRONMENT & TARGET HOST', colors),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 20.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDiagnosticRow(
                    'Environment',
                    AppConfig.effectiveEnv.toUpperCase(),
                    subtitle: AppConfig.isLocal ? 'Local/Development Target' : (AppConfig.isStaging ? 'Staging TLS Target' : 'Production Strict TLS'),
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'API Target Host',
                    AppConfig.apiHost,
                    subtitle: 'Sanitized Hostname (No paths or tokens)',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'WebSocket Host',
                    AppConfig.wsHost,
                    subtitle: 'Sanitized Hostname',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'Configuration Status',
                    AppConfig.isConfigured ? 'Valid' : 'Not Configured',
                    subtitle: AppConfig.configurationError ?? 'Ready for communication',
                    badgeColor: AppConfig.isConfigured ? colors.success : colors.critical,
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Safe API Endpoint Diagnostics
            _buildSectionHeader('CONFIRMED ENDPOINTS HEALTH', colors),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 20.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDiagnosticRow(
                    'GET /api/health',
                    _healthReachable == true
                        ? 'Reachable (${_healthStatusCode ?? 200})'
                        : (_healthReachable == false ? 'Unreachable' : 'Checking...'),
                    subtitle: _healthLatencyBucket ?? 'Latency bucket pending',
                    badgeColor: _healthReachable == true ? colors.success : (_healthReachable == false ? colors.critical : colors.warning),
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'GET /api/config',
                    _configReachable == true
                        ? 'Reachable (${_configStatusCode ?? 200})'
                        : (_configReachable == false ? 'Unreachable' : 'Checking...'),
                    subtitle: _configLatencyBucket ?? 'Latency bucket pending',
                    badgeColor: _configReachable == true ? colors.success : (_configReachable == false ? colors.critical : colors.warning),
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Network & Session Health
            _buildSectionHeader('DEVICE & SESSION STATE', colors),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 20.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDiagnosticRow(
                    'Device Physical Network',
                    isNetwork ? 'Connected' : 'Offline',
                    subtitle: isNetwork ? 'Wi-Fi / Cellular active' : 'No network interfaces active',
                    badgeColor: isNetwork ? colors.success : colors.critical,
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'WebSocket Telemetry Stream',
                    wsState.name.toUpperCase(),
                    subtitle: 'Real-time ingress channel (/api/ws)',
                    badgeColor: wsState == WsConnectionState.connected ? colors.success : colors.warning,
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildDiagnosticRow(
                    'User Session',
                    authState.isAuthenticated ? 'Active (In-Memory JWT)' : (authState.isSessionExpired ? 'Expired' : 'Guest / Unauthenticated'),
                    subtitle: 'JWT strictly stored in RAM, never disk',
                    badgeColor: authState.isAuthenticated ? colors.success : colors.textSecondary,
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Guarantee Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: colors.brandPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Zero Credential Exposure: Diagnostics never read or output JWT tokens, cookies, passwords, or payload internals.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusBanner(AppConnectionState state, AppColorScheme colors) {
    Color bannerColor;
    IconData icon;
    String title;
    String description;

    switch (state) {
      case AppConnectionState.live:
        bannerColor = colors.success;
        icon = Icons.check_circle_rounded;
        title = 'Connected & Streaming';
        description = 'Middle-man-3 API and live WebSocket telemetry active.';
        break;
      case AppConnectionState.connected:
        bannerColor = colors.success;
        icon = Icons.check_circle_outline_rounded;
        title = 'Connected';
        description = 'API reachable. Live stream standing by.';
        break;
      case AppConnectionState.syncing:
        bannerColor = colors.brandPrimary;
        icon = Icons.sync_rounded;
        title = 'Syncing Stream';
        description = 'Connecting to real-time security events...';
        break;
      case AppConnectionState.rateLimited:
        bannerColor = colors.warning;
        icon = Icons.timer_outlined;
        title = 'Rate Limited (HTTP 429)';
        description = 'Requests throttled temporarily. Please wait.';
        break;
      case AppConnectionState.sessionExpired:
        bannerColor = colors.warning;
        icon = Icons.lock_clock_outlined;
        title = 'Session Expired';
        description = 'Please sign in to refresh your authorization.';
        break;
      case AppConnectionState.networkOffline:
        bannerColor = colors.critical;
        icon = Icons.wifi_off_rounded;
        title = 'Device Offline';
        description = 'Check your Wi-Fi or cellular data connection.';
        break;
      case AppConnectionState.backendUnavailable:
        bannerColor = colors.critical;
        icon = Icons.cloud_off_rounded;
        title = 'Backend Unavailable';
        description = _errorMessage ?? 'Unable to reach LeukQuant middle-man-3 server.';
        break;
      case AppConnectionState.notConfigured:
        bannerColor = colors.warning;
        icon = Icons.warning_amber_rounded;
        title = 'Backend Not Configured';
        description = _errorMessage ?? 'Pass --dart-define=API_BASE_URL=... at build time.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: bannerColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(
    String label,
    String value, {
    String? subtitle,
    Color? badgeColor,
    required AppColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (badgeColor ?? colors.surface).withValues(alpha: badgeColor != null ? 0.15 : 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (badgeColor ?? colors.textSecondary).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? colors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColorScheme colors) {
    return Divider(
      height: 16,
      color: colors.textSecondary.withValues(alpha: 0.12),
    );
  }
}
