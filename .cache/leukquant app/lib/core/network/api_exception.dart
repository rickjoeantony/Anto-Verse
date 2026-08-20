// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

/// Clean domain exception model for API operations.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final bool isSessionExpired;
  final bool isOffline;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.isSessionExpired = false,
    this.isOffline = false,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your network and try again.',
          isOffline: true,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to reach the LeukQuant server. Please verify your connection.',
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
            return ApiException(
              message: serverMsg ?? 'Your session has expired. Please sign in again.',
              statusCode: 401,
              isSessionExpired: true,
            );
          case 403:
            return ApiException(
              message: serverMsg ?? 'Access restricted for this organization role.',
              statusCode: 403,
            );
          case 404:
            return ApiException(
              message: serverMsg ?? 'The requested resource was not found on the server.',
              statusCode: 404,
            );
          case 422:
            return ApiException(
              message: serverMsg ?? 'Invalid data provided. Please check your input.',
              statusCode: 422,
            );
          case 429:
            return ApiException(
              message: serverMsg ?? 'Rate limit exceeded. Please wait a moment before trying again.',
              statusCode: 429,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return const ApiException(
              message: 'LeukQuant service temporarily unavailable. Please retry shortly.',
              statusCode: 500,
            );
          default:
            return ApiException(
              message: serverMsg ?? 'An unexpected error occurred ($status).',
              statusCode: status,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.unknown:
      default:
        return const ApiException(
          message: 'Network connection error. Please verify your internet connection.',
          isOffline: true,
        );
    }
  }

  @override
  String toString() => message;
}
