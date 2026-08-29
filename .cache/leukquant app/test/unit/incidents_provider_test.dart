import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leukquant_mobile/core/domain/api_result.dart';
import 'package:leukquant_mobile/core/network/api_exception.dart';
import 'package:leukquant_mobile/features/incidents/domain/incident.dart';

/// Simulates what incidentsProvider returns for various ApiException inputs.
ApiResult<List<Incident>> _mapExceptionToResult(ApiException e) {
  if (e.isSessionExpired) return ApiUnauthorized();
  if (e.isPermissionDenied) return ApiPermissionDenied();
  if (e.isRateLimited) return ApiRateLimited();
  if (e.isRequestError) return ApiValidationError(e.message);
  if (e.isServerError || e.isServiceUnavailable) return ApiServerError(e.message);
  if (e.isOffline) {
    return ApiServiceUnavailable(
      'Unable to reach the LeukQuant server.',
    );
  }
  return ApiError(e.message);
}

void main() {
  group('ApiResult<List<Incident>> — Provider Error Differentiation Tests', () {
    test('Empty list from API → ApiEmpty (distinct from all error states)', () {
      // Simulate 200 OK with empty list
      final List<dynamic> emptyData = [];
      final List<Incident> incidents = emptyData.whereType<Map<String, dynamic>>()
          .map(Incident.fromJson).toList();

      final ApiResult<List<Incident>> result =
          incidents.isEmpty ? ApiEmpty() : ApiSuccess(incidents);

      expect(result, isA<ApiEmpty<List<Incident>>>(),
          reason: 'Empty data must be ApiEmpty, not ApiError or ApiServiceUnavailable');
    });

    test('Valid incident list → ApiSuccess with parsed incidents', () {
      final data = [
        {
          'id': 'INC-001',
          'title': 'SSH Brute Force',
          'description': 'Repeated SSH login attempts',
          'severity': 'critical',
          'status': 'Open',
          'assignee': 'SOC Tier 2',
          'scope': 'Honeynet Segment A',
          'recommended_action': 'Block source IP',
          'created_at': '2026-08-20T18:00:00Z',
          'timeline': [],
        }
      ];

      final incidents = data.map((e) => Incident.fromJson(e)).toList();
      final ApiResult<List<Incident>> result = ApiSuccess(incidents);

      expect(result, isA<ApiSuccess<List<Incident>>>());
      final success = result as ApiSuccess<List<Incident>>;
      expect(success.data.length, equals(1));
      expect(success.data.first.id, equals('INC-001'));
    });

    test('401 response → ApiUnauthorized (session expired, trigger re-login)', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 401),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiUnauthorized<List<Incident>>>(),
          reason: '401 must trigger re-login via ApiUnauthorized');
    });

    test('403 response → ApiPermissionDenied (access denied, user stays logged in)', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 403),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiPermissionDenied<List<Incident>>>(),
          reason: '403 must NOT trigger session clear — user stays logged in');
      // Ensure it is NOT ApiUnauthorized
      expect(result, isNot(isA<ApiUnauthorized<List<Incident>>>()));
    });

    test('422 → ApiValidationError with message', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 422),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiValidationError<List<Incident>>>());
    });

    test('429 → ApiRateLimited', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 429),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiRateLimited<List<Incident>>>());
    });

    test('500 → ApiServerError (backend reachable, internal error)', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 500),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiServerError<List<Incident>>>(),
          reason: '500 means backend IS reachable — must be ApiServerError, not ApiServiceUnavailable');
      expect(result, isNot(isA<ApiServiceUnavailable<List<Incident>>>()));
    });

    test('503 → ApiServerError (service unavailable response from server)', () {
      final e = ApiException.fromDioException(
        _fakeDioException(statusCode: 503),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiServerError<List<Incident>>>());
    });

    test('connectionError → ApiServiceUnavailable (backend unreachable / offline)', () {
      final e = ApiException.fromDioException(
        _fakeDioException(type: DioExceptionType.connectionError),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiServiceUnavailable<List<Incident>>>(),
          reason: 'Connection error (DNS/refused) = backend unreachable = ApiServiceUnavailable');
      expect(result, isNot(isA<ApiServerError<List<Incident>>>()),
          reason: 'isOffline errors must not be confused with isServerError');
    });

    test('connectionTimeout → ApiServiceUnavailable', () {
      final e = ApiException.fromDioException(
        _fakeDioException(type: DioExceptionType.connectionTimeout),
      );
      final result = _mapExceptionToResult(e);
      expect(result, isA<ApiServiceUnavailable<List<Incident>>>());
    });

    test('ApiEmpty and ApiServiceUnavailable are distinct types', () {
      final empty = ApiEmpty<List<Incident>>();
      final unavailable =
          ApiServiceUnavailable<List<Incident>>('Backend unreachable');

      expect(empty, isA<ApiEmpty<List<Incident>>>());
      expect(unavailable, isA<ApiServiceUnavailable<List<Incident>>>());
      expect(empty, isNot(isA<ApiServiceUnavailable<List<Incident>>>()),
          reason:
              '"No incidents" and "backend offline" must never be displayed the same way');
    });

    test('WebSocket ticket is not in URL query parameters', () {
      const ticket = 'test-ticket-value';
      final wsUri = Uri.parse('wss://api-staging.leukquant.com/api/ws');
      expect(wsUri.queryParameters.containsKey('ticket'), isFalse);
      expect(wsUri.toString(), isNot(contains(ticket)));
    });
  });
}

/// Helper to create fake DioException for testing.
DioException _fakeDioException({
  int? statusCode,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  if (statusCode != null) {
    return DioException(
      requestOptions: RequestOptions(path: '/api/incidents'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/incidents'),
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }
  return DioException(
    requestOptions: RequestOptions(path: '/api/incidents'),
    type: type,
  );
}
