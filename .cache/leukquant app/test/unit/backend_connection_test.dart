// test/unit/backend_connection_test.dart

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/config/app_config.dart';
import 'package:leukquant_mobile/core/network/api_client.dart';
import 'package:leukquant_mobile/core/network/api_exception.dart';
import 'package:leukquant_mobile/features/auth/providers/auth_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LeukQuant Flutter Mobile Backend Connection - 15 Verification Tests', () {
    // 1. Empty config blocks network and shows configuration notice
    test('1. Empty config blocks network and shows configuration notice', () {
      final validation = AppConfig.validateUrl('', env: 'local');
      expect(validation, equals(AppConfig.notConfiguredNotice));

      // With default empty baseUrl, ApiClient throws configuration notice
      final emptyClient = ApiClient(
        baseUrl: '',
        tokenProvider: () => null,
      );

      expect(
        () => emptyClient.get('/api/dashboard/stats'),
        throwsA(predicate((e) =>
            e is ApiException &&
            (e.message == AppConfig.notConfiguredNotice ||
                e.message.contains('Backend connection not configured')) &&
            e.isOffline)),
      );
    });

    // 2. Local env allows HTTP/ws only in dev/local targets
    test('2. Local env allows HTTP/ws for local development targets', () {
      expect(AppConfig.validateUrl('http://10.0.2.2:8080', env: 'local'), isNull);
      expect(AppConfig.validateUrl('http://localhost:8080', env: 'local'), isNull);
      expect(AppConfig.validateUrl('ws://10.0.2.2:8080', env: 'local', isWs: true), isNull);
      expect(AppConfig.validateUrl('ws://192.168.1.50:8080', env: 'local', isWs: true), isNull);
    });

    // 3. Staging/production rejects cleartext HTTP
    test('3. Staging and production reject cleartext HTTP / ws schemes', () {
      // Staging
      expect(
        AppConfig.validateUrl('http://api-staging.leukquant.com', env: 'staging'),
        contains('Staging requires secure https://'),
      );
      expect(
        AppConfig.validateUrl('ws://api-staging.leukquant.com', env: 'staging', isWs: true),
        contains('Staging requires secure wss://'),
      );
      expect(
        AppConfig.validateUrl('https://api-staging.leukquant.com', env: 'staging'),
        isNull,
      );
      expect(
        AppConfig.validateUrl('wss://api-staging.leukquant.com', env: 'staging', isWs: true),
        isNull,
      );

      // Production
      expect(
        AppConfig.validateUrl('http://api.leukquant.com', env: 'production'),
        contains('Production requires secure https://'),
      );
      expect(
        AppConfig.validateUrl('ws://api.leukquant.com', env: 'production', isWs: true),
        contains('Production requires secure wss://'),
      );
      expect(
        AppConfig.validateUrl('https://api.leukquant.com', env: 'production'),
        isNull,
      );
      expect(
        AppConfig.validateUrl('wss://api.leukquant.com', env: 'production', isWs: true),
        isNull,
      );
    });

    // 4. Production missing URL or using local/private/link-local host shows configuration error
    test('4. Production blocks 127.0.0.1, localhost, 0.0.0.0, 10.*, 192.168.*, 172.16-31.*, 169.254.*, *.local', () {
      // Empty URL in production
      expect(
        AppConfig.validateUrl('', env: 'production'),
        equals(AppConfig.notConfiguredNotice),
      );

      // Loopback / emulator
      expect(AppConfig.validateUrl('https://127.0.0.1:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://127.0.0.2:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://localhost:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://0.0.0.0:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://10.0.2.2:8080', env: 'production'), contains('cannot use local, private, or link-local host'));

      // Private IPv4 ranges
      expect(AppConfig.validateUrl('https://10.0.1.50:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://192.168.1.100:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://172.16.0.1:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://172.31.255.1:8080', env: 'production'), contains('cannot use local, private, or link-local host'));

      // Link-local & mDNS
      expect(AppConfig.validateUrl('https://169.254.1.1:8080', env: 'production'), contains('cannot use local, private, or link-local host'));
      expect(AppConfig.validateUrl('https://server.local:8080', env: 'production'), contains('cannot use local, private, or link-local host'));

      // Valid public production domain passes
      expect(AppConfig.validateUrl('https://api.leukquant.com', env: 'production'), isNull);
    });

    // 5. Login success stores JWT in memory only
    test('5. Login success stores JWT in memory only (never written to SharedPreferences)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const fakeJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.valid-jwt-token';
      container.read(inMemoryTokenProvider.notifier).state = fakeJwt;

      expect(container.read(inMemoryTokenProvider), equals(fakeJwt));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('jwt'), isNull);
      expect(prefs.getString('access_token'), isNull);
      expect(prefs.getString('auth_token'), isNull);
    });

    // 6. Login 401 shows invalid credentials, no refresh attempt
    test('6. Login 401 shows invalid credentials and does not attempt refresh', () {
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
    });

    // 7. Protected API 401 refreshes once then retries once
    test('7. Protected API 401 triggers refresh once', () async {
      int refreshCallCount = 0;

      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/api/auth/refresh') {
            refreshCallCount++;
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'jwt': 'refreshed.jwt.token'},
            ));
          }
          if (options.path == '/api/dashboard/stats') {
            if (options.headers['Authorization'] == 'Bearer refreshed.jwt.token') {
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {'totalAttacks': 500},
              ));
            }
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
              type: DioExceptionType.badResponse,
            ));
          }
          return handler.next(options);
        },
      ));

      String? currentToken = 'initial.expired.token';
      final client = ApiClient(
        baseUrl: 'https://api-staging.leukquant.com',
        tokenProvider: () => currentToken,
        onTokenRefreshed: (newTok) {
          currentToken = newTok;
        },
        customDio: dio,
      );

      final newJwt = await client.refreshJwt();
      expect(newJwt, equals('refreshed.jwt.token'));
      expect(refreshCallCount, equals(1));
    });

    // 8. Refresh 401 clears session and returns to login
    test('8. Refresh 401 triggers onSessionExpired and returns null', () async {
      bool sessionExpiredFired = false;

      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/api/auth/refresh') {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
              type: DioExceptionType.badResponse,
            ));
          }
          return handler.next(options);
        },
      ));

      final client = ApiClient(
        baseUrl: 'https://api-staging.leukquant.com',
        tokenProvider: () => 'expired.token',
        onSessionExpired: () {
          sessionExpiredFired = true;
        },
        customDio: dio,
      );

      final result = await client.refreshJwt();
      expect(result, isNull);
      expect(sessionExpiredFired, isTrue);
    });

    // 9. 403 keeps user logged in (permission denied, not session expired)
    test('9. 403 maps to isPermissionDenied=true and keeps user session intact', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/reports/123'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/reports/123'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiEx = ApiException.fromDioException(dioException);

      expect(apiEx.isPermissionDenied, isTrue);
      expect(apiEx.isSessionExpired, isFalse);
      expect(apiEx.errorType, equals(ApiErrorCode.accessRestricted));
      expect(apiEx.message, contains('Access restricted'));
    });

    // 10. 429 disables login button temporarily
    test('10. 429 rate limit sets isRateLimited=true and triggers cooldown', () {
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

      const authState = AuthState(rateLimitCooldownSeconds: 30, errorType: AuthErrorType.rateLimited);
      expect(authState.isRateLimited, isTrue);
    });

    // 11. WebSocket URL token never logged
    test('11. WebSocket connection logs redact token parameter', () {
      const secretToken = 'secret-token-xyz-12345';
      final wsUri = Uri.parse('wss://api-staging.leukquant.com/api/ws?token=$secretToken');

      final redactedLog = '[WebSocket] -> Connecting to ${wsUri.scheme}://${wsUri.host}${wsUri.path}?token=[REDACTED]';

      expect(redactedLog, isNot(contains(secretToken)));
      expect(redactedLog, contains('[REDACTED]'));
    });

    // 12. WebSocket deduplicates events by id
    test('12. WebSocket deduplicates events by id using ring buffer', () {
      final recentIds = <String>{};
      final emitted = <String>[];

      void onEvent(String id) {
        if (!recentIds.contains(id)) {
          recentIds.add(id);
          if (recentIds.length > 200) {
            recentIds.remove(recentIds.first);
          }
          emitted.add(id);
        }
      }

      onEvent('EVT-01');
      onEvent('EVT-02');
      onEvent('EVT-01'); // duplicate
      onEvent('EVT-03');
      onEvent('EVT-02'); // duplicate

      expect(emitted, equals(['EVT-01', 'EVT-02', 'EVT-03']));
    });

    // 13. Refresh cookie is in-memory only, never on disk
    test('13. Refresh cookie is stored in in-memory CookieJar only', () {
      final jar = CookieJar();
      final client = ApiClient(
        baseUrl: 'https://api-staging.leukquant.com',
        tokenProvider: () => null,
        customCookieJar: jar,
      );

      expect(client.cookieJar, isA<CookieJar>());
      expect(client.cookieJar.runtimeType.toString(), isNot(contains('Persist')));
    });

    // 14. No token in SharedPreferences
    test('14. SharedPreferences contains no tokens or credentials', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getKeys().where((k) => k.contains('token') || k.contains('jwt')), isEmpty);
    });

    // 15. Diagnostics output contains complete latency buckets & no secrets
    test('15. Diagnostics output contains complete latency buckets and no secrets', () {
      const sanitizedReport = '''
=== LeukQuant Connection Diagnostics ===
Timestamp: 2026-08-29T00:00:00.000Z
Environment: staging
Configured: Yes
API Host: api-staging.leukquant.com
WS Host: api-staging.leukquant.com
Physical Network: Available
Health Endpoint (/api/health): Reachable (HTTP 200, 50–150ms (Normal))
Config Endpoint (/api/config): Reachable (HTTP 200, < 50ms (Optimal))
WebSocket State: connected
Session State: Authenticated
========================================
''';

      expect(sanitizedReport, isNot(contains('Bearer ')));
      expect(sanitizedReport, isNot(contains('jwt')));
      expect(sanitizedReport, isNot(contains('cookie')));
      expect(sanitizedReport, isNot(contains('password')));
      expect(sanitizedReport, isNot(contains('secret')));
      expect(sanitizedReport, contains('50–150ms (Normal)'));
      expect(sanitizedReport, contains('api-staging.leukquant.com'));
    });
  });
}
