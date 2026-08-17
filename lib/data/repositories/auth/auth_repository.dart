import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../datasources/auth/auth_token_storage.dart';
import '../../models/auth/apple_login_request.dart';
import '../../models/auth/login_token_model.dart';

class AuthRepository {
  const AuthRepository({AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? const AuthTokenStorage();

  final AuthTokenStorage _tokenStorage;

  Future<void> logout() async {
    await DioClient.instance.post('/api/auth/logout');
    await _tokenStorage.clear();
  }

  Future<LoginTokenModel> loginWithApple(AppleLoginRequest request) async {
    final deviceId = await _tokenStorage.readOrCreateDeviceId();
    return _login(
      path: '/api/auth/apple',
      data: {...request.toJson(), 'deviceId': deviceId},
    );
  }

  Future<LoginTokenModel> loginWithKakaoAccessToken(
    String kakaoAccessToken,
  ) async {
    return _login(
      path: '/api/auth/kakao/native',
      data: {'accessToken': kakaoAccessToken},
    );
  }

  Future<LoginTokenModel> _login({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await DioClient.instance.post(path, data: data);

      if (result is! Map<String, dynamic>) {
        throw const ApiException('로그인 응답 형식이 올바르지 않습니다.');
      }

      final token = LoginTokenModel.fromJson(result);
      await _tokenStorage.save(
        accessToken: token.accessToken,
        tokenType: token.tokenType,
        userId: token.userId,
      );
      return token;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('로그인 응답을 처리하지 못했습니다.');
    }
  }
}
