import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/datasources/auth/apple_login_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  test('Apple에는 해시 nonce를 보내고 서버 요청에는 원본 nonce를 담는다', () async {
    String? receivedNonce;
    final service = AppleLoginService(
      nonceGenerator: () => 'raw-nonce',
      platformProvider: () => 'IOS',
      credentialProvider: ({required nonce, webAuthenticationOptions}) async {
        receivedNonce = nonce;
        expect(webAuthenticationOptions, isNull);
        return const AuthorizationCredentialAppleID(
          userIdentifier: 'apple-user',
          givenName: '현영',
          familyName: '조',
          authorizationCode: 'authorization-code',
          email: 'user@example.com',
          identityToken: 'identity-token',
          state: null,
        );
      },
    );

    final request = await service.login();

    expect(receivedNonce, sha256.convert('raw-nonce'.codeUnits).toString());
    expect(request.nonce, 'raw-nonce');
    expect(request.platform, 'IOS');
    expect(request.identityToken, 'identity-token');
  });

  test('사용자가 Apple 로그인을 취소하면 취소 예외로 변환한다', () async {
    final service = AppleLoginService(
      nonceGenerator: () => 'raw-nonce',
      platformProvider: () => 'IOS',
      credentialProvider: ({required nonce, webAuthenticationOptions}) async {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: '사용자 취소',
        );
      },
    );

    await expectLater(
      service.login(),
      throwsA(isA<AppleLoginCanceledException>()),
    );
  });

  test('identityToken이 없으면 잘못된 인증 정보로 처리한다', () async {
    final service = AppleLoginService(
      nonceGenerator: () => 'raw-nonce',
      platformProvider: () => 'IOS',
      credentialProvider: ({required nonce, webAuthenticationOptions}) async {
        return const AuthorizationCredentialAppleID(
          userIdentifier: 'apple-user',
          givenName: null,
          familyName: null,
          authorizationCode: 'authorization-code',
          email: null,
          identityToken: null,
          state: null,
        );
      },
    );

    await expectLater(
      service.login(),
      throwsA(isA<AppleLoginInvalidCredentialException>()),
    );
  });
}
