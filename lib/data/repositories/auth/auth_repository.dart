import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../datasources/auth/auth_token_storage.dart';
import '../../models/auth/login_token_model.dart';

class AuthRepository {
  AuthRepository({AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? const AuthTokenStorage();

  final AuthTokenStorage _tokenStorage;

  Future<LoginTokenModel> loginWithKakaoAccessToken(
    String kakaoAccessToken,
  ) async {
    try {
      final result = await DioClient.instance.post(
        '/api/auth/kakao/native',
        data: {'accessToken': kakaoAccessToken},
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('로그인 응답 형식이 올바르지 않습니다.');
      }

      final token = LoginTokenModel.fromJson(result);
      await _tokenStorage.save(
        accessToken: token.accessToken,
        tokenType: token.tokenType,
      );
      return token;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('로그인 응답을 처리하지 못했습니다.');
    }
  }
}
