// lib/core/domain/api_result.dart

/// Typed result wrapper for all API data-fetching operations.
/// Replaces bare List<T> returns that silently swallow errors.
///
/// Error semantics:
/// - [ApiEmpty]: 200 OK with empty data. Backend is healthy, no items exist.
/// - [ApiUnauthorized]: 401. Session expired or JWT invalid. Trigger re-login.
/// - [ApiPermissionDenied]: 403. User is authenticated but lacks access to this resource.
///   The user REMAINS logged in. Do NOT clear session.
/// - [ApiRateLimited]: 429. Too many requests. Show backoff message.
/// - [ApiValidationError]: 422. Client request data is invalid.
/// - [ApiServerError]: 500/502. Backend is reachable but has an internal error.
/// - [ApiServiceUnavailable]: 503/504 or offline. Backend unreachable.
/// - [ApiError]: Any other unexpected error.
sealed class ApiResult<T> {}

/// 200 OK with non-empty data.
final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

/// 200 OK with an empty collection. Backend is healthy — no items exist yet.
final class ApiEmpty<T> extends ApiResult<T> {}

/// 401 Unauthorized. Session has expired or JWT is invalid.
/// Action: clear session and redirect to login.
final class ApiUnauthorized<T> extends ApiResult<T> {}

/// 403 Forbidden. User is authenticated but lacks permission for this resource.
/// Action: show access-denied message. Do NOT log the user out.
final class ApiPermissionDenied<T> extends ApiResult<T> {}

/// 429 Too Many Requests. Rate limit exceeded.
final class ApiRateLimited<T> extends ApiResult<T> {}

/// 422 Unprocessable Entity. Request data failed server-side validation.
final class ApiValidationError<T> extends ApiResult<T> {
  final String message;
  ApiValidationError(this.message);
}

/// 500/502. Backend is reachable and responded, but encountered an internal error.
/// isOffline is false — the server was reached.
final class ApiServerError<T> extends ApiResult<T> {
  final String message;
  ApiServerError(this.message);
}

/// 503/504 or infrastructure failure (timeout, DNS, connection refused).
/// Backend could not be reached or is temporarily unavailable.
final class ApiServiceUnavailable<T> extends ApiResult<T> {
  final String message;
  ApiServiceUnavailable(this.message);
}

/// Any other unexpected error not covered by the above states.
final class ApiError<T> extends ApiResult<T> {
  final String message;
  ApiError(this.message);
}
