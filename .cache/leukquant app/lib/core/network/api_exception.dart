// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

/// Enum representing standardized API error categories for middle-man-3 integration.
enum ApiErrorCode {
  invalidCredentials,
  sessionExpired,
  accessRestricted,
  notFound,
  validationError,
  rateLimited,
  serverError,
  serviceUnavailable,
  backendUnavailable,
  deviceOffline,
  unknown,
}

/// Clean domain exception model for API operations.
/// Error classification strictly follows HTTP semantics and mobile security rules:
/// - 401 login → invalidCredentials
/// - 401 API → sessionExpired (triggers in-memory JWT clear and login redirect)
/// - 403 → accessRestricted
/// - 404 → notFound
/// - 422 → validationError
/// - 429 → rateLimited
/// - 500/502 → serverError
/// - 503 → serviceUnavailable
/// - timeout/DNS/connection refused → backendUnavailable
/// - no internet → deviceOffline
///
/// Stack traces and raw backend details are NEVER exposed in UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorCode errorType;

  /// True ONLY when the backend cannot be reached at all:
  /// connection timeout, receive timeout, send timeout, connection error (DNS/refused/socket).
  final bool isOffline;

  /// True for 401 on protected endpoints (session expired / invalid JWT).
  final bool isSessionExpired;

  /// True for 401 on login endpoint (wrong email/password).
  final bool isInvalidCredentials;

  /// True for 403 — user is authenticated but lacks permission.
  final bool isPermissionDenied;

  /// True for 404 — resource not found.
  final bool isNotFound;

  /// True for 422 — request validation failed.
  final bool isRequestError;

  /// True for 429 — rate limit exceeded.
  final bool isRateLimited;

  /// True for 500/502 — backend server error.
  final bool isServerError;

  /// True for 503/504 — service temporarily unavailable.
  final bool isServiceUnavailable;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorType = ApiErrorCode.unknown,
    this.isOffline = false,
    this.isSessionExpired = false,
    this.isInvalidCredentials = false,
    this.isPermissionDenied = false,
    this.isNotFound = false,
    this.isRequestError = false,
    this.isRateLimited = false,
    this.isServerError = false,
    this.isServiceUnavailable = false,
  });

  factory ApiException.fromDioException(DioException error, {bool isLoginRequest = false, bool isRefreshRequest = false}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Backend unavailable. Please check your connection and retry.',
          statusCode: null,
          errorType: ApiErrorCode.backendUnavailable,
          isOffline: true,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to reach the LeukQuant server. Please verify your connection.',
          statusCode: null,
          errorType: ApiErrorCode.backendUnavailable,
          isOffline: true,
        );

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMsg;
        if (data is Map<String, dynamic>) {
          serverMsg = (data['message'] ?? data['detail'] ?? data['error'])?.toString();
        }

        switch (status) {
          case 401:
            if (isLoginRequest) {
              return const ApiException(
                message: 'Invalid email or password.',
                statusCode: 401,
                errorType: ApiErrorCode.invalidCredentials,
                isInvalidCredentials: true,
              );
            }
            return ApiException(
              message: serverMsg ?? 'Session expired. Please sign in again.',
              statusCode: 401,
              errorType: ApiErrorCode.sessionExpired,
              isSessionExpired: true,
            );

          case 403:
            return ApiException(
              message: serverMsg ?? 'Access restricted for this account.',
              statusCode: 403,
              errorType: ApiErrorCode.accessRestricted,
              isPermissionDenied: true,
            );

          case 404:
            return ApiException(
              message: serverMsg ?? 'The requested resource was not found.',
              statusCode: 404,
              errorType: ApiErrorCode.notFound,
              isNotFound: true,
            );

          case 422:
            return ApiException(
              message: serverMsg ?? 'Invalid request data. Please check your input.',
              statusCode: 422,
              errorType: ApiErrorCode.validationError,
              isRequestError: true,
            );

          case 429:
            return const ApiException(
              message: 'Too many attempts. Please wait a moment and try again.',
              statusCode: 429,
              errorType: ApiErrorCode.rateLimited,
              isRateLimited: true,
            );

          case 500:
          case 502:
            return ApiException(
              message: 'The LeukQuant server encountered an internal issue. Please retry.',
              statusCode: status,
              errorType: ApiErrorCode.serverError,
              isServerError: true,
            );

          case 503:
          case 504:
            return ApiException(
              message: 'Service temporarily unavailable. Please retry shortly.',
              statusCode: status,
              errorType: ApiErrorCode.serviceUnavailable,
              isServiceUnavailable: true,
            );

          default:
            return ApiException(
              message: serverMsg ?? 'An unexpected error occurred ($status).',
              statusCode: status,
              errorType: ApiErrorCode.unknown,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          errorType: ApiErrorCode.unknown,
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Security certificate verification failed.',
          errorType: ApiErrorCode.backendUnavailable,
          isOffline: true,
        );

      case DioExceptionType.unknown:
      default:
        return const ApiException(
          message: 'Network connection error. Please verify your internet connection.',
          errorType: ApiErrorCode.deviceOffline,
          isOffline: true,
        );
    }
  }

  @override
  String toString() => message;
}
