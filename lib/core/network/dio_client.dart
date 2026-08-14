// DIO 싱글톤 클라이언트를 관리합니다.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

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
  Future<String?> Function()? _accessTokenProvider;

  void attachAccessTokenProvider(Future<String?> Function() provider) {
    _accessTokenProvider = provider;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _send(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(String path, {Object? data}) {
    return _send(() => _dio.post(path, data: data));
  }

  Future<dynamic> patch(String path, {Object? data}) {
    return _send(() => _dio.patch(path, data: data));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return _unwrap(response);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  // 서버 응답의 기본 형태를 정제합니다.
  // { isSuccess, code, message, result } 포맷을 공통 규격으로 가정합니다.
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
