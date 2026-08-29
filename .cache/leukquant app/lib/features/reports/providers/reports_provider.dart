// lib/features/reports/providers/reports_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/report_item.dart';

/// Provider returning typed ApiResult<List<ReportItem>> from GET /api/reports.
///
/// Error differentiation:
/// - ApiSuccess: reports fetched and parsed
/// - ApiEmpty: 200 OK but no reports exist yet
/// - ApiUnauthorized: 401 — session expired
/// - ApiPermissionDenied: 403 — access denied, user stays logged in
/// - ApiRateLimited: 429
/// - ApiValidationError: 422
/// - ApiServerError: 500/502 — backend reachable, internal error
/// - ApiServiceUnavailable: 503/504 or offline
/// - ApiError: other unexpected error
final reportsProvider =
    FutureProvider<ApiResult<List<ReportItem>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get<dynamic>('/api/reports');
    final data = response.data;
    final List<ReportItem> list = [];

    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(ReportItem.fromJson(item));
        }
      }
    } else if (data is Map<String, dynamic> && data['reports'] is List) {
      for (final item in data['reports'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(ReportItem.fromJson(item));
        }
      }
    }

    return list.isEmpty ? ApiEmpty() : ApiSuccess(list);
  } on ApiException catch (e) {
    if (e.isSessionExpired) return ApiUnauthorized();
    if (e.isPermissionDenied) return ApiPermissionDenied();
    if (e.isRateLimited) return ApiRateLimited();
    if (e.isRequestError) return ApiValidationError(e.message);
    if (e.isServerError) return ApiServerError(e.message);
    if (e.isOffline) {
      return ApiServiceUnavailable(
        'Unable to reach the LeukQuant server. Please check your connection.',
      );
    }
    return ApiError(e.message);
  } catch (e) {
    return ApiError('Unexpected error loading reports: $e');
  }
});
