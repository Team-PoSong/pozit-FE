import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginCanceledException implements Exception {
  const KakaoLoginCanceledException();
}

class KakaoLoginService {
  const KakaoLoginService();

  Future<String> login() async {
    if (await isKakaoTalkInstalled()) {
      try {
        final token = await UserApi.instance.loginWithKakaoTalk();
        return token.accessToken;
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          throw const KakaoLoginCanceledException();
        }
      }
    }

    try {
      final token = await UserApi.instance.loginWithKakaoAccount();
      return token.accessToken;
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        throw const KakaoLoginCanceledException();
      }
      rethrow;
    }
  }
}
