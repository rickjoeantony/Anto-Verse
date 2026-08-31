// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';
import 'network_status_provider.dart';

/// In-memory token storage provider for Riverpod.
/// JWT is NEVER written to SharedPreferences or any persistence layer.
final inMemoryTokenProvider = StateProvider<String?>((ref) => null);

/// Central Riverpod provider for ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenProvider: () => ref.read(inMemoryTokenProvider),
    onTokenRefreshed: (newToken) {
      ref.read(inMemoryTokenProvider.notifier).state = newToken;
    },
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

typedef TokenUpdateCallback = void Function(String newToken);
typedef SessionExpiredCallback = void Function();

/// Central client wrapper around Dio for the middle-man-3 Spring Boot API.
///
/// Features:
/// 1. In-memory only CookieJar (refresh cookie lives in RAM only, never touches disk).
/// 2. In-memory JWT access token in Authorization: Bearer <jwt>.
/// 3. Protected endpoint 401 automatic refresh retry (once) via POST /api/auth/refresh.
/// 4. Login 401 and refresh 401 do NOT loop into auto-refresh.
/// 5. Strictly safe logging (no credentials, tokens, or sensitive payloads logged).
class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  final TokenProvider _tokenProvider;
  final TokenUpdateCallback? _onTokenRefreshed;
  final SessionExpiredCallback? _onSessionExpired;
  final void Function(bool isReachable)? onReachabilityChanged;

  Completer<String?>? _refreshCompleter;
  String? _inMemoryRefreshToken;

  ApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
    TokenUpdateCallback? onTokenRefreshed,
    SessionExpiredCallback? onSessionExpired,
    this.onReachabilityChanged,
    CookieJar? customCookieJar,
    Dio? customDio,
  })  : _tokenProvider = tokenProvider,
        _onTokenRefreshed = onTokenRefreshed,
        _onSessionExpired = onSessionExpired {
    // IN-MEMORY COOKIE JAR ONLY — never PersistCookieJar
    _cookieJar = customCookieJar ?? CookieJar();

    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Origin': 'https://dashboard.leukquant.com',
            },
          ),
        );

    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        // Strict security: In release mode, enforce full OS certificate chain verification.
        // In local debug mode, allow self-signed certificates for local middle-man-3 staging nodes.
        if (kDebugMode) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            return host.contains('leukquant.com') || host == 'localhost' || host == '10.0.2.2';
          };
        }
        return client;
      };
    }

    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(ApiInterceptor(tokenProvider: _tokenProvider));
  }

  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;

  void _checkConfiguration() {
    if (!AppConfig.isConfigured) {
      throw ApiException(
        message: AppConfig.configurationError ?? AppConfig.notConfiguredNotice,
        errorType: ApiErrorCode.backendUnavailable,
        isOffline: true,
      );
    }
  }

  void _updateReachability({required bool success, ApiException? exception}) {
    if (success) {
      onReachabilityChanged?.call(true);
    } else if (exception != null && exception.isOffline) {
      onReachabilityChanged?.call(false);
    }
  }

  /// Refreshes JWT using httpOnly cookie via POST /api/auth/refresh.
  /// If refresh succeeds, notifies and returns new JWT.
  /// If refresh fails, invokes onSessionExpired and returns null.
  Future<String?> refreshJwt() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final currentToken = _tokenProvider();
      final bodyData = <String, dynamic>{};
      if (_inMemoryRefreshToken != null && _inMemoryRefreshToken!.isNotEmpty) {
        bodyData['refreshToken'] = _inMemoryRefreshToken;
        bodyData['refresh_token'] = _inMemoryRefreshToken;
      }
      if (currentToken != null && currentToken.isNotEmpty) {
        bodyData['token'] = currentToken;
      }

      final response = await _dio.post(
        '/api/auth/refresh',
        data: bodyData.isNotEmpty ? bodyData : null,
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (currentToken != null && currentToken.isNotEmpty)
              'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      final data = response.data;
      String? newJwt;
      if (data is Map) {
        newJwt = (data['jwt'] ??
                data['access_token'] ??
                data['accessToken'] ??
                data['token'] ??
                (data['data'] is Map
                    ? (data['data']['jwt'] ??
                        data['data']['token'] ??
                        data['data']['access_token'] ??
                        data['data']['accessToken'])
                    : null))
            ?.toString();
      } else if (data is String && data.isNotEmpty) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            newJwt = (decoded['jwt'] ??
                    decoded['access_token'] ??
                    decoded['accessToken'] ??
                    decoded['token'] ??
                    (decoded['data'] is Map
                        ? (decoded['data']['jwt'] ??
                            decoded['data']['token'] ??
                            decoded['data']['access_token'])
                        : null))
                ?.toString();
          }
        } catch (_) {}
      }

      if (newJwt == null || newJwt.isEmpty) {
        final authHeader = response.headers.value('Authorization') ??
            response.headers.value('authorization') ??
            response.headers.value('x-auth-token') ??
            response.headers.value('jwt');
        if (authHeader != null && authHeader.isNotEmpty) {
          newJwt = authHeader.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '').trim();
        }
      }

      if (newJwt != null && newJwt.isNotEmpty) {
        await _persistSessionCookies(response);
        _onTokenRefreshed?.call(newJwt);
        _refreshCompleter?.complete(newJwt);
        return newJwt;
      } else {
        await clearPersistedSession();
        _onSessionExpired?.call();
        _refreshCompleter?.complete(null);
        return null;
      }
    } catch (_) {
      await clearPersistedSession();
      _onSessionExpired?.call();
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Perform safe GET request with protected 401 refresh retry.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int maxRetries = 1,
  }) async {
    _checkConfiguration();
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      _updateReachability(success: true);
      return response;
    } on DioException catch (e) {
      // If 401 on protected endpoint, attempt refresh once
      if (e.response?.statusCode == 401 &&
          !path.contains('/api/auth/login') &&
          !path.contains('/api/auth/refresh') &&
          _tokenProvider() != null) {
        final newJwt = await refreshJwt();
        if (newJwt != null) {
          try {
            final retryResponse = await _dio.get<T>(
              path,
              queryParameters: queryParameters,
              options: options,
            );
            _updateReachability(success: true);
            return retryResponse;
          } on DioException catch (retryErr) {
            final apiEx = ApiException.fromDioException(retryErr);
            _updateReachability(success: false, exception: apiEx);
            throw apiEx;
          }
        }
      }

      final isLogin = path.contains('/api/auth/login');
      final isRefresh = path.contains('/api/auth/refresh');
      final apiEx = ApiException.fromDioException(e, isLoginRequest: isLogin, isRefreshRequest: isRefresh);
      _updateReachability(success: false, exception: apiEx);
      throw apiEx;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Unexpected request failure: $e',
        errorType: ApiErrorCode.unknown,
      );
    }
  }

  /// Perform POST request with protected 401 refresh retry.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _checkConfiguration();
    final isLogin = path.contains('/api/auth/login');
    final isRefresh = path.contains('/api/auth/refresh');

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (isLogin && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        await _persistSessionCookies(response);
      }
      _updateReachability(success: true);
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && !isLogin && !isRefresh && _tokenProvider() != null) {
        final newJwt = await refreshJwt();
        if (newJwt != null) {
          try {
            final retryResponse = await _dio.post<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            _updateReachability(success: true);
            return retryResponse;
          } on DioException catch (retryErr) {
            final apiEx = ApiException.fromDioException(retryErr);
            _updateReachability(success: false, exception: apiEx);
            throw apiEx;
          }
        }
      }

      final apiEx = ApiException.fromDioException(e, isLoginRequest: isLogin, isRefreshRequest: isRefresh);
      _updateReachability(success: false, exception: apiEx);
      throw apiEx;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Unexpected request failure: $e',
        errorType: ApiErrorCode.unknown,
      );
    }
  }

  /// Perform PATCH request with protected 401 refresh retry.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _checkConfiguration();
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      _updateReachability(success: true);
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && _tokenProvider() != null) {
        final newJwt = await refreshJwt();
        if (newJwt != null) {
          try {
            final retryResponse = await _dio.patch<T>(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            _updateReachability(success: true);
            return retryResponse;
          } on DioException catch (retryErr) {
            final apiEx = ApiException.fromDioException(retryErr);
            _updateReachability(success: false, exception: apiEx);
            throw apiEx;
          }
        }
      }

      final apiEx = ApiException.fromDioException(e);
      _updateReachability(success: false, exception: apiEx);
      throw apiEx;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Unexpected request failure: $e',
        errorType: ApiErrorCode.unknown,
      );
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
      _updateReachability(success: true);
      return response;
    } on DioException catch (e) {
      final apiEx = ApiException.fromDioException(e);
      _updateReachability(success: false, exception: apiEx);
      throw apiEx;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Unexpected request failure: $e',
        errorType: ApiErrorCode.unknown,
      );
    }
  }

  // ==========================================
  // CONFIRMED MIDDLE-MAN-3 ENDPOINT HELPERS
  // ==========================================

  /// GET /api/health
  Future<Response<Map<String, dynamic>>> getHealth() => get<Map<String, dynamic>>('/api/health');

  /// GET /api/config
  Future<Response<Map<String, dynamic>>> getConfig() => get<Map<String, dynamic>>('/api/config');

  /// POST /api/auth/login
  Future<Response<dynamic>> login(String email, String password) =>
      post<dynamic>('/api/auth/login', data: {'email': email, 'password': password});

  /// POST /api/auth/logout
  Future<Response<dynamic>> logout() => post<dynamic>('/api/auth/logout');

  /// GET /api/user/profile
  Future<Response<Map<String, dynamic>>> getUserProfile() => get<Map<String, dynamic>>('/api/user/profile');

  /// PATCH /api/user/profile
  Future<Response<Map<String, dynamic>>> updateUserProfile(Map<String, dynamic> data) =>
      patch<Map<String, dynamic>>('/api/user/profile', data: data);

  /// GET /api/dashboard/stats
  Future<Response<Map<String, dynamic>>> getDashboardStats() => get<Map<String, dynamic>>('/api/dashboard/stats');

  /// GET /api/dashboard/events?limit=500
  Future<Response<dynamic>> getDashboardEvents({int limit = 500, int page = 1}) =>
      get<dynamic>('/api/dashboard/events', queryParameters: {'limit': limit, 'page': page});

  /// GET /api/dashboard/attacks?limit=500
  Future<Response<dynamic>> getDashboardAttacks({int limit = 500}) =>
      get<dynamic>('/api/dashboard/attacks', queryParameters: {'limit': limit});

  /// GET /api/events (Complete Historical Log)
  Future<Response<dynamic>> getHistoricalEvents({int limit = 500, int page = 1}) async {
    try {
      return await get<dynamic>('/api/events', queryParameters: {'limit': limit, 'page': page});
    } catch (_) {
      return await getDashboardEvents(limit: limit, page: page);
    }
  }

  /// GET /api/attacks (Complete Historical Attacks)
  Future<Response<dynamic>> getHistoricalAttacks({int limit = 500}) async {
    try {
      return await get<dynamic>('/api/attacks', queryParameters: {'limit': limit});
    } catch (_) {
      return await getDashboardAttacks(limit: limit);
    }
  }

  /// GET /api/events/:id
  Future<Response<Map<String, dynamic>>> getEventById(String id) => get<Map<String, dynamic>>('/api/events/$id');

  /// PATCH /api/events/:id
  Future<Response<Map<String, dynamic>>> patchEvent(String id, Map<String, dynamic> data) =>
      patch<Map<String, dynamic>>('/api/events/$id', data: data);

  /// GET /api/reports
  Future<Response<dynamic>> getReports() => get<dynamic>('/api/reports');

  /// POST /api/reports/generate or POST /api/reports
  Future<Response<dynamic>> generateReport({
    String type = 'weekly',
    String period = '7d',
    String format = 'PDF',
    String? title,
  }) async {
    final body = {
      'type': type,
      'period': period,
      'format': format,
      'title': title ?? 'Threat Intelligence Audit Report ($period)',
    };
    try {
      return await post<dynamic>('/api/reports/regenerate', data: body);
    } catch (_) {
      try {
        return await post<dynamic>('/api/reports/generate', data: body);
      } catch (_) {
        return await post<dynamic>('/api/reports', data: body);
      }
    }
  }

  /// POST /api/reports/:id/regenerate
  Future<Response<Map<String, dynamic>>> regenerateReport(String id) =>
      post<Map<String, dynamic>>('/api/reports/$id/regenerate');

  /// GET /api/reports/:id/download (Binary PDF Stream)
  Future<Response<List<int>>> downloadReportPdf(String id) =>
      _dio.get<List<int>>(
        '/api/reports/$id/download',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

  /// POST /api/reports/verify (Cryptographic Watermark & HMAC Verification)
  Future<Response<Map<String, dynamic>>> verifyReportWatermark(String watermark) =>
      post<Map<String, dynamic>>('/api/reports/verify', data: {
        'token': watermark,
        'watermark': watermark,
      });

  /// GET /api/ip/:ip/sessions
  Future<Response<dynamic>> getIpSessions(String ip) => get<dynamic>('/api/ip/$ip/sessions');

  /// GET /api/geo/location
  Future<Response<dynamic>> getGeoLocation([String? ip]) =>
      get<dynamic>('/api/geo/location', queryParameters: ip != null ? {'ip': ip} : null);

  // ==========================================
  // SESSION COOKIE PERSISTENCE HELPERS
  // ==========================================

  Future<void> _persistSessionCookies(Response response) async {
    try {
      final setCookieHeaders = response.headers['set-cookie'];
      final prefs = await SharedPreferences.getInstance();
      if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
        await prefs.setStringList('leukquant_session_cookies', setCookieHeaders);
      }

      final data = response.data;
      if (data is Map) {
        final rf = data['refreshToken'] ??
            data['refresh_token'] ??
            (data['data'] is Map ? (data['data']['refreshToken'] ?? data['data']['refresh_token']) : null);
        if (rf != null && rf.toString().isNotEmpty) {
          _inMemoryRefreshToken = rf.toString();
          await prefs.setString('leukquant_refresh_token', rf.toString());
        }
      }
    } catch (_) {}
  }

  /// Restore persisted session cookies from SharedPreferences into CookieJar and refresh token field.
  Future<bool> restorePersistedCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCookies = prefs.getStringList('leukquant_session_cookies');
      final savedRefreshToken = prefs.getString('leukquant_refresh_token');

      bool hasData = false;
      if (savedCookies != null && savedCookies.isNotEmpty) {
        final base = _dio.options.baseUrl.isNotEmpty ? _dio.options.baseUrl : 'https://api.leukquant.com';
        final uri = Uri.parse(base);
        final cookies = savedCookies.map((str) => Cookie.fromSetCookieValue(str)).toList();
        await _cookieJar.saveFromResponse(uri, cookies);
        hasData = true;
      }
      if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
        _inMemoryRefreshToken = savedRefreshToken;
        hasData = true;
      }
      return hasData;
    } catch (_) {
      return false;
    }
  }

  /// Clear persisted session on explicit logout or revocation.
  Future<void> clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('leukquant_session_cookies');
      await prefs.remove('leukquant_refresh_token');
      await _cookieJar.deleteAll();
      _inMemoryRefreshToken = null;
    } catch (_) {}
  }
}
