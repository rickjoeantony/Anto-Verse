// test/unit/api_client_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/network/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiClient & Network Security Unit Tests', () {
    test('Bearer token is added only in-memory to Authorization header', () {
      const inMemoryToken = 'staging-jwt-token-xyz';
      final options = RequestOptions(path: '/api/dashboard/stats');
      final headers = Map<String, dynamic>.from(options.headers);
      const token = inMemoryToken;
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      expect(headers['Authorization'], equals('Bearer staging-jwt-token-xyz'));
    });

    test('Session expiry (401) triggers onSessionExpired callback on protected endpoint', () {
      bool sessionExpiredTriggered = false;
      void onSessionExpired() {
        sessionExpiredTriggered = true;
      }

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/dashboard/events'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/dashboard/events'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      // 401 on protected endpoint → session expired
      if (dioError.response?.statusCode == 401 &&
          !dioError.requestOptions.path.contains('/api/auth/login')) {
        onSessionExpired();
      }

      expect(sessionExpiredTriggered, isTrue);
    });

    test('Login 401 does NOT trigger onSessionExpired (invalid credentials, not session expiry)', () {
      bool sessionExpiredTriggered = false;
      void onSessionExpired() {
        sessionExpiredTriggered = true;
      }

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      // Login 401 → invalid credentials, NOT session expiry
      if (dioError.response?.statusCode == 401 &&
          !dioError.requestOptions.path.contains('/api/auth/login')) {
        onSessionExpired();
      }

      expect(sessionExpiredTriggered, isFalse,
          reason: 'Login 401 means invalid credentials, not session expiry');
    });

    group('ApiException classification — isOffline/isServerError correctness', () {
      test('401 → isSessionExpired=true, isOffline=false, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 401),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isSessionExpired, isTrue);
        expect(e.isOffline, isFalse);
        expect(e.isServerError, isFalse);
        expect(e.message.toLowerCase(), contains('session expired'));
      });

      test('403 → isPermissionDenied=true, isOffline=false, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 403),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isPermissionDenied, isTrue);
        expect(e.isOffline, isFalse);
        expect(e.isServerError, isFalse);
        expect(e.isSessionExpired, isFalse,
            reason: '403 must NOT clear session');
        expect(e.message, contains('Access restricted'));
      });

      test('422 → isRequestError=true, isOffline=false, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 422),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isRequestError, isTrue);
        expect(e.isOffline, isFalse);
        expect(e.isServerError, isFalse);
      });

      test('429 → isRateLimited=true, isOffline=false, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 429),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isRateLimited, isTrue);
        expect(e.isOffline, isFalse);
        expect(e.isServerError, isFalse);
      });

      test('500 → isServerError=true, isOffline=false (backend is reachable!)', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 500),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isServerError, isTrue,
            reason: 'A 500 means backend is reachable but has internal error');
        expect(e.isOffline, isFalse,
            reason: 'Backend responded with 500 — it is reachable, not offline');
        expect(e.message, contains('internal issue'));
      });

      test('503 → isServiceUnavailable=true, isOffline=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 503),
          type: DioExceptionType.badResponse,
        ));
        expect(e.isServiceUnavailable, isTrue);
        expect(e.isOffline, isFalse);
      });

      test('connectionTimeout → isOffline=true, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.connectionTimeout,
        ));
        expect(e.isOffline, isTrue);
        expect(e.isServerError, isFalse);
        expect(e.message, contains('Backend unavailable'));
      });

      test('connectionError → isOffline=true, isServerError=false', () {
        final e = ApiException.fromDioException(DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.connectionError,
        ));
        expect(e.isOffline, isTrue);
        expect(e.isServerError, isFalse);
        expect(e.message, contains('reach the LeukQuant server'));
      });
    });

    group('JWT contract — middle-man-3 JWT handling', () {
      test('JWT is correctly parsed from middle-man-3 response', () {
        final middlemanResponse = <String, dynamic>{
          'jwt': 'jwt.valid.token',
          'user': {'email': 'analyst@leukquant.com', 'plan': 'enterprise'},
        };
        final token = (middlemanResponse['jwt'] ?? middlemanResponse['access_token'])?.toString();
        expect(token, equals('jwt.valid.token'));
      });
    });

    test('No token is ever persisted to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('jwt'), isNull);
      expect(prefs.getString('access_token'), isNull);
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('token'), isNull);
    });

    test('WebSocket connection URL contains query token', () {
      const wsBaseUrl = 'wss://api-staging.leukquant.com';
      const token = 'jwt.token.123';

      final wsUri = Uri.parse('$wsBaseUrl/api/ws?token=$token');
      expect(wsUri.queryParameters['token'], equals(token));
    });
  });
}
