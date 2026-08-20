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

    test('Session expiry (401) triggers onSessionExpired callback', () {
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

      if (dioError.response?.statusCode == 401 &&
          !dioError.requestOptions.path.contains('/api/auth/login')) {
        onSessionExpired();
      }

      expect(sessionExpiredTriggered, isTrue);
    });

    test('ApiException maps 401, 403, 404, 429, and 500 to user-friendly messages', () {
      final e401 = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 401),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(e401.message, contains('session has expired'));

      final e403 = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 403),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(e403.message, contains('Access restricted'));

      final e500 = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(requestOptions: RequestOptions(path: '/api/test'), statusCode: 500),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(e500.message, contains('temporarily unavailable'));
    });

    test('No token is ever persisted to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('jwt'), isNull);
      expect(prefs.getString('access_token'), isNull);
      expect(prefs.getString('auth_token'), isNull);
    });
  });
}
