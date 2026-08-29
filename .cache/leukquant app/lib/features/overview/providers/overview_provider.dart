// lib/features/overview/providers/overview_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/overview_summary.dart';

/// Provider for overview metrics and health summary connected to GET /api/dashboard/stats.
///
/// Error differentiation:
/// - ApiSuccess: valid JSON metrics parsed
/// - ApiEmpty: 200 OK with empty body
/// - ApiUnauthorized: 401 session expired
/// - ApiPermissionDenied: 403 access restricted
/// - ApiRateLimited: 429
/// - ApiValidationError: 422
/// - ApiServerError: 500/502
/// - ApiServiceUnavailable: 503/offline ("Awaiting backend data")
final overviewSummaryProvider =
    FutureProvider<ApiResult<OverviewSummary>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.getDashboardStats();
    if (response.data != null) {
      return ApiSuccess(OverviewSummary.fromJson(response.data!));
    }
    return ApiEmpty();
  } on ApiException catch (e) {
    if (e.isSessionExpired) return ApiUnauthorized();
    if (e.isPermissionDenied) return ApiPermissionDenied();
    if (e.isRateLimited) return ApiRateLimited();
    if (e.isRequestError) return ApiValidationError(e.message);
    if (e.isServerError) return ApiServerError(e.message);
    if (e.isOffline || e.errorType == ApiErrorCode.backendUnavailable) {
      return ApiServiceUnavailable('Awaiting backend data');
    }
    return ApiError(e.message);
  } catch (e) {
    return ApiError('Awaiting backend data');
  }
});
