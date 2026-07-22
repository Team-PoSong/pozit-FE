import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginCanceledException implements Exception {
  const KakaoLoginCanceledException();
}

class KakaoLoginService {
  const KakaoLoginService({
    Future<bool> Function()? isTalkInstalled,
    Future<String> Function()? loginWithTalk,
    Future<String> Function()? loginWithAccount,
  }) : _isTalkInstalled = isTalkInstalled,
       _loginWithTalk = loginWithTalk,
       _loginWithAccount = loginWithAccount;

  final Future<bool> Function()? _isTalkInstalled;
  final Future<String> Function()? _loginWithTalk;
  final Future<String> Function()? _loginWithAccount;

  Future<String> login() async {
    final isTalkInstalled = _isTalkInstalled ?? isKakaoTalkInstalled;
    final loginWithTalk = _loginWithTalk ?? _defaultLoginWithTalk;
    final loginWithAccount = _loginWithAccount ?? _defaultLoginWithAccount;

    if (await isTalkInstalled()) {
      try {
        return await loginWithTalk();
      } on PlatformException catch (error) {
        if (error.code == 'CANCELED') {
          throw const KakaoLoginCanceledException();
        }
        rethrow;
      }
    }

    try {
      return await loginWithAccount();
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        throw const KakaoLoginCanceledException();
      }
      rethrow;
    }
  }

  static Future<String> _defaultLoginWithTalk() async {
    final token = await UserApi.instance.loginWithKakaoTalk();
    return token.accessToken;
  }

  static Future<String> _defaultLoginWithAccount() async {
    final token = await UserApi.instance.loginWithKakaoAccount();
    return token.accessToken;
  }
}
