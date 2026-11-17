import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../session/active_workspace_store.dart';
import '../session/session_expiry_notifier.dart';
import '../storage/secure_storage.dart';

/// Attaches the access token and the active workspace, refreshes the token on
/// 401 and logs (masked) traffic.
///
/// Extends [QueuedInterceptor] so concurrent 401 responses are handled one at a
/// time: the first one refreshes the token, the rest see that the stored token
/// changed and simply retry with it. The refresh endpoint is called only once.
class ApiInterceptor extends QueuedInterceptor {
  ApiInterceptor({
    required this.secureStorage,
    required this.sessionExpiryNotifier,
    this.activeWorkspaceStore,
    Dio? refreshDio,
  }) : _injectedRefreshDio = refreshDio;

  final SecureStorage secureStorage;
  final SessionExpiryNotifier sessionExpiryNotifier;

  /// Source of the `X-Workspace-Id` header. Null, or no workspace chosen,
  /// means the header is not sent (creator accounts never have one).
  final ActiveWorkspaceStore? activeWorkspaceStore;

  /// Routes that list the caller's workspaces. The backend must not narrow
  /// them by the header, so it is never attached there.
  static const Set<String> _workspaceDiscoveryPaths = {
    ApiConstants.workspaces,
    ApiConstants.workspaceOptions,
  };
  final Dio? _injectedRefreshDio;

  /// Bare client (no interceptors) used for token refresh and retries, so a
  /// failing refresh can never loop back into this interceptor.
  late final Dio _refreshDio = _injectedRefreshDio ?? _createRefreshDio();

  static const List<String> _sensitiveKeys = [
    'password',
    'token',
    'access_token',
    'refresh_token',
    'accessToken',
    'refreshToken',
    'authorization',
    'secret',
  ];

  bool get _isLoggingEnabled => AppConfig.instance.enableLogging && kDebugMode;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final workspaceId = activeWorkspaceStore?.workspaceId;
    if (workspaceId != null &&
        !options.headers.containsKey(ApiConstants.workspaceIdHeader) &&
        !_workspaceDiscoveryPaths.contains(options.path)) {
      options.headers[ApiConstants.workspaceIdHeader] = workspaceId;
    }

    if (_isLoggingEnabled) _logRequest(options);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isLoggingEnabled) _logResponse(response);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isLoggingEnabled) {
      debugPrint(
        '[API ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint(
        'Status: ${err.response?.statusCode} | Message: ${err.message}',
      );
    }

    if (err.response?.statusCode != 401 || _isAuthEndpoint(err)) {
      return handler.next(err);
    }

    // Another queued request may already have refreshed the token.
    final sentToken = _bearerToken(err.requestOptions.headers['Authorization']);
    final currentToken = await secureStorage.getAccessToken();
    if (currentToken != null &&
        currentToken.isNotEmpty &&
        currentToken != sentToken) {
      return _retry(err, currentToken, handler);
    }

    final newToken = await _refreshAccessToken();
    if (newToken != null) {
      return _retry(err, newToken, handler);
    }

    // Refresh is impossible: end the session so the app returns to login.
    await secureStorage.clearAuthTokens();
    sessionExpiryNotifier.notifyExpired();
    handler.next(err);
  }

  bool _isAuthEndpoint(DioException err) {
    final path = err.requestOptions.path;
    return path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.refreshToken);
  }

  String? _bearerToken(Object? header) {
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring('Bearer '.length);
  }

  /// Calls the refresh endpoint and stores the new tokens.
  /// Returns the new access token, or null when the session cannot be renewed.
  Future<String?> _refreshAccessToken() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _refreshDio.post<dynamic>(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final body = response.data;
      final data = body is Map<String, dynamic> ? body : <String, dynamic>{};
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      final newAccessToken = payload['access_token'] ?? payload['accessToken'];
      final newRefreshToken =
          payload['refresh_token'] ?? payload['refreshToken'];

      if (newAccessToken is! String || newAccessToken.isEmpty) return null;

      await secureStorage.setAccessToken(newAccessToken);
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await secureStorage.setRefreshToken(newRefreshToken);
      }
      return newAccessToken;
    } on DioException catch (e) {
      if (_isLoggingEnabled) {
        debugPrint('[API] Token refresh failed: ${e.response?.statusCode}');
      }
      return null;
    }
  }

  Future<void> _retry(
    DioException err,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    options.headers['Authorization'] = 'Bearer $accessToken';
    try {
      final response = await _refreshDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Dio _createRefreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(
          seconds: AppConstants.connectTimeoutSeconds,
        ),
        receiveTimeout: const Duration(
          seconds: AppConstants.receiveTimeoutSeconds,
        ),
        sendTimeout: const Duration(seconds: AppConstants.sendTimeoutSeconds),
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    debugPrint('--> ${options.method} ${options.uri}');
    debugPrint('Headers: ${_sanitizeData(options.headers)}');
    if (options.data != null) {
      debugPrint('Body: ${_sanitizeData(options.data)}');
    }
  }

  void _logResponse(Response response) {
    debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    if (response.data != null) {
      debugPrint('Response: ${_sanitizeData(response.data)}');
    }
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final keyStr = key.toString().toLowerCase();
        if (_sensitiveKeys.any(
          (sensitive) => keyStr.contains(sensitive.toLowerCase()),
        )) {
          return MapEntry(key, '***MASKED***');
        }
        return MapEntry(key, _sanitizeData(value));
      });
    } else if (data is List) {
      return data.map(_sanitizeData).toList();
    } else if (data is String) {
      try {
        return jsonEncode(_sanitizeData(jsonDecode(data)));
      } on FormatException {
        return data; // Not JSON: plain strings carry no masked keys.
      }
    }
    return data;
  }
}
