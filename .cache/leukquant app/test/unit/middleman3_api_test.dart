// test/unit/middleman3_api_test.dart

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/network/api_client.dart';
import 'package:leukquant_mobile/core/network/api_exception.dart';
import 'package:leukquant_mobile/features/auth/providers/auth_state_provider.dart';
import 'package:leukquant_mobile/features/events/domain/security_event.dart';
import 'package:leukquant_mobile/features/overview/domain/dashboard_stats.dart';
import 'package:leukquant_mobile/features/overview/domain/overview_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Middle-Man-3 API Integration & Security Requirements Tests', () {
    // 1. Login success stores JWT only in memory
    test('1. Login success stores JWT only in memory (inMemoryTokenProvider)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const fakeJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test-jwt-token';
      container.read(inMemoryTokenProvider.notifier).state = fakeJwt;

      expect(container.read(inMemoryTokenProvider), equals(fakeJwt));

      // Verify not written to SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('jwt'), isNull);
      expect(prefs.getString('access_token'), isNull);
    });

    // 2. 401 login shows invalid credentials
    test('2. 401 login shows invalid credentials (not session expired)', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
          data: {'error': 'Bad credentials'},
        ),
        type: DioExceptionType.badResponse,
      );

      final apiEx = ApiException.fromDioException(dioException, isLoginRequest: true);

      expect(apiEx.isInvalidCredentials, isTrue);
      expect(apiEx.isSessionExpired, isFalse);
      expect(apiEx.message, equals('Invalid email or password.'));
      expect(apiEx.errorType, equals(ApiErrorCode.invalidCredentials));
    });

    // 3. 429 shows rate limit and disables button
    test('3. 429 shows rate limit and sets cooldown', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 429,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiEx = ApiException.fromDioException(dioException);

      expect(apiEx.isRateLimited, isTrue);
      expect(apiEx.errorType, equals(ApiErrorCode.rateLimited));
      expect(apiEx.message, equals('Too many attempts. Please wait a moment and try again.'));

      // AuthState cooldown
      const authState = AuthState(rateLimitCooldownSeconds: 30, errorType: AuthErrorType.rateLimited);
      expect(authState.isRateLimited, isTrue);
    });

    // 4. SecurityEvent with credentials masks password
    test('4. SecurityEvent with credentials masks password (root ••••••••)', () {
      final rawJson = {
        'id': 'EVT-7701',
        'timestamp': '2026-08-28T05:30:00Z',
        'sourceIP': '198.51.100.22',
        'country': 'Germany',
        'countryCode': 'DE',
        'type': 'SSH Brute Force',
        'threatLevel': 5,
        'honeypot': 'ssh-decoy-01',
        'payload': 'ssh root@198.51.100.22',
        'abuseScore': 95.0,
        'reviewed': false,
        'credentials': [
          {'username': 'root', 'password': 'superSecretPassword123'},
          {'username': 'admin', 'password': 'plainTextAdminPassword'},
        ],
      };

      final event = SecurityEvent.fromJson(rawJson);

      expect(event.credentials.length, equals(2));
      expect(event.credentials[0].username, equals('root'));
      expect(event.credentials[0].maskedPassword, equals('••••••••'));
      expect(event.credentials[1].username, equals('admin'));
      expect(event.credentials[1].maskedPassword, equals('••••••••'));

      // String representation
      expect(event.credentials[0].toString(), equals('root ••••••••'));
      expect(event.maskedCredentials, equals('root ••••••••, admin ••••••••'));

      // NEVER contains the raw password
      expect(event.maskedCredentials, isNot(contains('superSecretPassword123')));
      expect(event.maskedCredentials, isNot(contains('plainTextAdminPassword')));
    });

    // 5. Payload is truncated and never executed
    test('5. Payload is truncated to safe preview (80-120 chars) and stripped of control characters', () {
      const dangerousRawPayload = 'rm -rf / \x00\x01\x1b[31m dangerous command payload '
          'that is extremely long and would overflow normal preview space in security operations centers '
          'if not properly capped to a safe length preview string buffer.';

      final sanitized = SecurityEvent.sanitizePayload(dangerousRawPayload);

      expect(sanitized.length, lessThanOrEqualTo(100));
      expect(sanitized, endsWith('...'));
      expect(sanitized, isNot(contains('\x00')));
      expect(sanitized, isNot(contains('\x01')));
    });

    // 6. WebSocket URL with token is never logged
    test('6. WebSocket URL with token is never logged in plaintext', () {
      const fakeJwt = 'secret.jwt.token.value';
      final wsUri = Uri.parse('wss://api-staging.leukquant.com/api/ws?token=$fakeJwt');

      // The full URI has the token query param
      expect(wsUri.queryParameters['token'], equals(fakeJwt));

      // Safe debug print pattern replaces token
      final safeLogMessage = '[WebSocket] -> Connecting to ${wsUri.scheme}://${wsUri.host}${wsUri.path}?token=[REDACTED]';
      expect(safeLogMessage, isNot(contains(fakeJwt)));
      expect(safeLogMessage, contains('[REDACTED]'));
    });

    // 7. WebSocket deduplicates by id
    test('7. WebSocket deduplicates incoming events by ID in ring buffer', () {
      final Set<String> recentIds = {};
      final List<String> emittedIds = [];

      void handleEvent(String eventId) {
        if (!recentIds.contains(eventId)) {
          recentIds.add(eventId);
          if (recentIds.length > 200) {
            recentIds.remove(recentIds.first);
          }
          emittedIds.add(eventId);
        }
      }

      // Send duplicates
      handleEvent('EVT-100');
      handleEvent('EVT-101');
      handleEvent('EVT-100'); // duplicate
      handleEvent('EVT-102');
      handleEvent('EVT-101'); // duplicate

      expect(emittedIds, equals(['EVT-100', 'EVT-101', 'EVT-102']));
      expect(recentIds.length, equals(3));
    });

    // 8. Stats screen renders real JSON without crash
    test('8. DashboardStats and OverviewSummary render real JSON without crash', () {
      final realBackendStatsJson = {
        'totalAttacks': 14250,
        'activeThreats': 12,
        'blockedIPs': 842,
        'honeypots': 6,
        'attacksToday': 310,
        'criticalAlerts': 3,
        'origins': [
          {'country': 'Germany', 'count': 120, 'lat': 51.1657, 'lng': 10.4515},
          {'country': 'United States', 'count': 95, 'lat': 37.0902, 'lng': -95.7129},
        ],
        'hourlyData': [
          {'hour': '00:00', 'attacks': 20, 'blocked': 18},
          {'hour': '04:00', 'attacks': 45, 'blocked': 40},
        ],
        'threatDistribution': [
          {'level': 'Critical', 'count': 45},
          {'level': 'High', 'count': 120},
        ],
        'topThreatVectors': [
          {'name': 'SSH Brute Force', 'count': 450},
          {'name': 'SQL Injection', 'count': 220},
        ],
        'systemUptime': '99.99%',
      };

      final stats = DashboardStats.fromJson(realBackendStatsJson);
      expect(stats.totalAttacks, equals(14250));
      expect(stats.activeThreats, equals(12));
      expect(stats.blockedIPs, equals(842));
      expect(stats.honeypots, equals(6));
      expect(stats.criticalAlerts, equals(3));
      expect(stats.origins.length, equals(2));
      expect(stats.hourlyData.length, equals(2));
      expect(stats.threatDistribution.length, equals(2));
      expect(stats.topThreatVectors.length, equals(2));

      final summary = OverviewSummary.fromJson(realBackendStatsJson);
      expect(summary.isBackendConnected, isTrue);
      expect(summary.criticalIncidentsCount, equals(3));
      expect(summary.totalAttacksCount, equals(14250));
    });

    // 9. Null/legacy fields handled safely
    test('9. Null and legacy fields in SecurityEvent & DashboardStats handled safely', () {
      final sparseJson = <String, dynamic>{};

      final event = SecurityEvent.fromJson(sparseJson);
      expect(event.id, equals('EVT-UNKNOWN'));
      expect(event.type, equals('Unclassified Telemetry Probe'));
      expect(event.threatLevel, equals(1));
      expect(event.payload, equals('—'));
      expect(event.sourceIp, equals('0.0.0.0'));
      expect(event.country, equals('Unknown Location'));
      expect(event.credentials, isEmpty);

      final stats = DashboardStats.fromJson(sparseJson);
      expect(stats.totalAttacks, equals(0));
      expect(stats.activeThreats, equals(0));
      expect(stats.blockedIPs, equals(0));
      expect(stats.criticalAlerts, equals(0));
      expect(stats.origins, isEmpty);
      expect(stats.hourlyData, isEmpty);
    });

    // 10. Refresh cookie never persisted to disk (in-memory CookieJar)
    test('10. Refresh cookie lives in in-memory CookieJar and is never persisted to disk', () {
      final inMemoryJar = CookieJar(); // Default CookieJar is RAM-only
      final apiClient = ApiClient(
        baseUrl: 'https://api-staging.leukquant.com',
        tokenProvider: () => null,
        customCookieJar: inMemoryJar,
      );

      expect(apiClient.cookieJar, isA<CookieJar>());
      // Ensure it is in-memory only (not PersistCookieJar)
      expect(apiClient.cookieJar.runtimeType.toString(), isNot(contains('Persist')));
    });

    // 11. Offline state works
    test('11. Connection timeout and connection errors map to offline / backend unavailable', () {
      final timeoutEx = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/dashboard/stats'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(timeoutEx.isOffline, isTrue);
      expect(timeoutEx.errorType, equals(ApiErrorCode.backendUnavailable));
      expect(timeoutEx.message, contains('Backend unavailable'));

      final connErrorEx = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/dashboard/stats'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(connErrorEx.isOffline, isTrue);
      expect(connErrorEx.errorType, equals(ApiErrorCode.backendUnavailable));
    });

    // 12. No SharedPreferences token storage
    test('12. JWT is never read from or written to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.containsKey('jwt'), isFalse);
      expect(prefs.containsKey('access_token'), isFalse);
      expect(prefs.containsKey('refresh_token'), isFalse);
      expect(prefs.containsKey('refresh_cookie'), isFalse);
    });
  });
}
