import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

const Duration _kTransferConnectTimeout = Duration(seconds: 10);

/// S3 presigned URL 등 DioClient의 baseUrl/인증 인터셉터를 타지 않는
/// 파일 송수신 전용 Dio 인스턴스를 만든다. 기본 Dio()에는 타임아웃이 없어
/// 네트워크가 끊기면 요청이 영원히 끝나지 않을 수 있다.
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
      ),
    );
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
