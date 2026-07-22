import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_token_storage.dart';
import 'login_token.dart';

class AuthRepository {
  AuthRepository({Dio? dio, AuthTokenStorage? tokenStorage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              contentType: Headers.jsonContentType,
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
      _tokenStorage = tokenStorage ?? const AuthTokenStorage();

  final Dio _dio;
  final AuthTokenStorage _tokenStorage;

  Future<LoginToken> loginWithKakaoAccessToken(String kakaoAccessToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/kakao/native',
        data: {'accessToken': kakaoAccessToken},
      );
      final body = response.data;
      final result = body?['result'];

      if (body?['isSuccess'] != true || result is! Map<String, dynamic>) {
        throw const AuthRepositoryException('로그인 응답 형식이 올바르지 않습니다.');
      }

      final token = LoginToken.fromJson(result);
      await _tokenStorage.save(token);
      return token;
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message'] as String?
          : null;
      throw AuthRepositoryException(message ?? '서버 로그인에 실패했습니다.');
    } on AuthRepositoryException {
      rethrow;
    } catch (_) {
      throw const AuthRepositoryException('로그인 응답을 처리하지 못했습니다.');
    }
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
