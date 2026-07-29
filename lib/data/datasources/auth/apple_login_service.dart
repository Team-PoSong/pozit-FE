import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';
import '../../models/auth/apple_login_request.dart';

class AppleLoginCanceledException implements Exception {
  const AppleLoginCanceledException();
}

class AppleLoginInvalidCredentialException implements Exception {
  const AppleLoginInvalidCredentialException();
}

typedef AppleCredentialProvider =
    Future<AuthorizationCredentialAppleID> Function({
      required String nonce,
      WebAuthenticationOptions? webAuthenticationOptions,
    });

class AppleLoginService {
  const AppleLoginService({
    AppleCredentialProvider? credentialProvider,
    String Function()? nonceGenerator,
    String Function()? platformProvider,
  }) : _credentialProvider = credentialProvider,
       _nonceGenerator = nonceGenerator,
       _platformProvider = platformProvider;

  final AppleCredentialProvider? _credentialProvider;
  final String Function()? _nonceGenerator;
  final String Function()? _platformProvider;

  Future<AppleLoginRequest> login() async {
    final rawNonce = (_nonceGenerator ?? generateNonce)();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final platform = (_platformProvider ?? _currentPlatform)();

    try {
      final credential = await (_credentialProvider ?? _requestCredential)(
        nonce: hashedNonce,
        webAuthenticationOptions: _webAuthenticationOptions(platform),
      );
      final identityToken = credential.identityToken;

      if (identityToken == null || identityToken.isEmpty) {
        throw const AppleLoginInvalidCredentialException();
      }

      return AppleLoginRequest(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        nonce: rawNonce,
        platform: platform,
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AppleLoginCanceledException();
      }
      rethrow;
    }
  }

  static String _currentPlatform() {
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    throw UnsupportedError('Apple 로그인은 iOS와 Android에서만 지원합니다.');
  }

  static WebAuthenticationOptions? _webAuthenticationOptions(String platform) {
    if (platform != 'ANDROID') return null;
    if (AppConfig.appleServiceId.isEmpty ||
        AppConfig.appleRedirectUri.isEmpty) {
      throw StateError(
        'Android Apple 로그인에 APPLE_SERVICE_ID와 '
        'APPLE_REDIRECT_URI 설정이 필요합니다.',
      );
    }

    return WebAuthenticationOptions(
      clientId: AppConfig.appleServiceId,
      redirectUri: Uri.parse(AppConfig.appleRedirectUri),
    );
  }

  static Future<AuthorizationCredentialAppleID> _requestCredential({
    required String nonce,
    WebAuthenticationOptions? webAuthenticationOptions,
  }) {
    return SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
      webAuthenticationOptions: webAuthenticationOptions,
    );
  }
}
