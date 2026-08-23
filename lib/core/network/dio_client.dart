import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

const Duration _kTransferConnectTimeout = Duration(seconds: 10);

Dio createTransferDio({Duration? sendTimeout, Duration? receiveTimeout}) {
  return Dio(
    BaseOptions(
      connectTimeout: _kTransferConnectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    ),
  );
}

class DioClient {
  DioClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _accessTokenProvider?.call();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_shouldRefresh(error)) {
            handler.next(error);
            return;
          }
          try {
            final refreshResult = await _refreshAccessToken();
            if (refreshResult == _TokenRefreshResult.sessionChanged) {
              handler.next(error);
              return;
            }
            if (refreshResult == _TokenRefreshResult.failed) {
              await _onRefreshFailed?.call();
              handler.next(error);
              return;
            }
            final accessToken = await _accessTokenProvider?.call();
            final request = error.requestOptions;
            request.extra[_retryAfterRefreshKey] = true;
            request.headers['Authorization'] = 'Bearer $accessToken';
            handler.resolve(await _dio.fetch<dynamic>(request));
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('→ ${options.method} ${options.uri.path}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '← ${response.statusCode} ${response.requestOptions.method} '
              '${response.requestOptions.uri.path}',
            );
            handler.next(response);
          },
          onError: (error, handler) {
            final data = error.response?.data;
            final code = data is Map<String, dynamic> ? data['code'] : null;
            debugPrint(
              '← ${error.response?.statusCode ?? '-'} '
              '${error.requestOptions.method} ${error.requestOptions.uri.path}'
              '${code == null ? '' : ' [$code]'}',
            );
            handler.next(error);
          },
        ),
      );
    }
  }

  static final DioClient instance = DioClient._();

  final Dio _dio;
  static const String _retryAfterRefreshKey = 'retriedAfterTokenRefresh';
  Future<String?> Function()? _accessTokenProvider;
  Future<String?> Function()? _refreshTokenProvider;
  Future<void> Function({
    required String accessToken,
    required String refreshToken,
  })?
  _onTokensReissued;
  Future<void> Function()? _onRefreshFailed;
  Future<_TokenRefreshResult>? _refreshInFlight;

  void attachAccessTokenProvider(Future<String?> Function() provider) {
    _accessTokenProvider = provider;
  }

  void attachTokenHandlers({
    required Future<String?> Function() accessTokenProvider,
    required Future<String?> Function() refreshTokenProvider,
    required Future<void> Function({
      required String accessToken,
      required String refreshToken,
    })
    onTokensReissued,
    required Future<void> Function() onRefreshFailed,
  }) {
    _accessTokenProvider = accessTokenProvider;
    _refreshTokenProvider = refreshTokenProvider;
    _onTokensReissued = onTokensReissued;
    _onRefreshFailed = onRefreshFailed;
  }

  bool _shouldRefresh(DioException error) {
    return error.response?.statusCode == 401 &&
        error.requestOptions.path != '/api/auth/reissue' &&
        error.requestOptions.extra[_retryAfterRefreshKey] != true &&
        _refreshTokenProvider != null &&
        _onTokensReissued != null;
  }

  Future<_TokenRefreshResult> _refreshAccessToken() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final refresh = _performTokenRefresh();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() => _refreshInFlight = null);
  }

  Future<_TokenRefreshResult> _performTokenRefresh() async {
    final refreshToken = await _refreshTokenProvider?.call();
    if (refreshToken == null || refreshToken.isEmpty) {
      return _TokenRefreshResult.failed;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    try {
      final response = await refreshDio.post<dynamic>(
        '/api/auth/reissue',
        data: {'refreshToken': refreshToken},
      );
      if (await _refreshTokenProvider?.call() != refreshToken) {
        return _TokenRefreshResult.sessionChanged;
      }
      final body = response.data;
      if (body is! Map<String, dynamic> || body['isSuccess'] != true) {
        return _TokenRefreshResult.failed;
      }
      final result = body['result'];
      if (result is! Map<String, dynamic>) return _TokenRefreshResult.failed;
      final newAccessToken = result['accessToken'] as String?;
      final newRefreshToken = result['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) {
        return _TokenRefreshResult.failed;
      }
      await _onTokensReissued!(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return _TokenRefreshResult.refreshed;
    } catch (_) {
      return await _refreshTokenProvider?.call() == refreshToken
          ? _TokenRefreshResult.failed
          : _TokenRefreshResult.sessionChanged;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _send(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> patch(String path, {Object? data}) {
    return _send(() => _dio.patch(path, data: data));
  }

  Future<dynamic> delete(String path, {Object? data}) {
    return _send(() => _dio.delete(path, data: data));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return _unwrap(response);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  dynamic _unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const ApiException('서버 응답 형식이 올바르지 않습니다.');
    }
    if (body['isSuccess'] != true) {
      throw ApiException.fromServerResponse(
        body,
        statusCode: response.statusCode,
      );
    }
    return body['result'];
  }
}

enum _TokenRefreshResult { refreshed, failed, sessionChanged }
