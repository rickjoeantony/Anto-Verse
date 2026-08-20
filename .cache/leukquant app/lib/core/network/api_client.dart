// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';
import 'network_status_provider.dart';

/// In-memory token storage provider for Riverpod.
final inMemoryTokenProvider = StateProvider<String?>((ref) => null);

/// Central Riverpod provider for ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  final token = ref.watch(inMemoryTokenProvider);
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenProvider: () => token,
    onSessionExpired: () {
      ref.read(inMemoryTokenProvider.notifier).state = null;
    },
    onReachabilityChanged: (isReachable) {
      ref.read(apiReachabilityProvider.notifier).state = isReachable
          ? ApiReachability.reachable
          : ApiReachability.unreachable;
    },
  );
});

/// Central client wrapper around Dio for middle-man-3 staging API.
class ApiClient {
  late final Dio _dio;
  final void Function(bool isReachable)? onReachabilityChanged;

  ApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
    SessionExpiredCallback? onSessionExpired,
    this.onReachabilityChanged,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      ApiInterceptor(
        tokenProvider: tokenProvider,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  void _checkConfiguration() {
    if (!AppConfig.isConfigured) {
      throw ApiException(message: AppConfig.notConfiguredNotice);
    }
  }

  /// Perform safe GET request with optional retry for transient failures.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int maxRetries = 2,
  }) async {
    _checkConfiguration();
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        final response = await _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
        );
        onReachabilityChanged?.call(true);
        return response;
      } on DioException catch (e) {
        final isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;

        if (isRetryable && attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
          onReachabilityChanged?.call(false);
        }
        throw ApiException.fromDioException(e);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(message: 'Unexpected request failure: $e');
      }
    }
  }

  /// Perform POST request (mutations are not retried automatically).
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _checkConfiguration();
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      onReachabilityChanged?.call(true);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        onReachabilityChanged?.call(false);
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected request failure: $e');
    }
  }

  /// Perform PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _checkConfiguration();
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      onReachabilityChanged?.call(true);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        onReachabilityChanged?.call(false);
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected request failure: $e');
    }
  }

  /// Perform DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _checkConfiguration();
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      onReachabilityChanged?.call(true);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        onReachabilityChanged?.call(false);
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected request failure: $e');
    }
  }
}
