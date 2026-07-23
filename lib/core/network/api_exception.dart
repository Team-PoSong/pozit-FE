// 서버 및 네트워크 에러를 공통으로 처리합니다.

import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  factory ApiException.fromServerResponse(
    Map<String, dynamic> body, {
    int? statusCode,
  }) {
    return ApiException(
      body['message'] as String? ?? '요청이 실패했습니다.',
      code: body['code'] as String?,
      statusCode: statusCode,
    );
  }

  factory ApiException.fromDioException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException.fromServerResponse(
        data,
        statusCode: error.response?.statusCode,
      );
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ApiException(
        '서버 응답이 지연되고 있어요. 잠시 후 다시 시도해 주세요.',
      ),
      DioExceptionType.connectionError => const ApiException(
        '네트워크 연결을 확인해 주세요.',
      ),
      _ => ApiException(
        '요청을 처리하지 못했어요.',
        statusCode: error.response?.statusCode,
      ),
    };
  }

  @override
  String toString() => message;
}
