import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/auth/apple_login_request.dart';

void main() {
  test('Apple 로그인 요청을 서버 전송 형식으로 변환한다', () {
    const request = AppleLoginRequest(
      identityToken: 'identity-token',
      authorizationCode: 'authorization-code',
      nonce: 'raw-nonce',
      platform: 'IOS',
      email: 'user@example.com',
      givenName: '현영',
      familyName: '조',
    );

    expect(request.toJson(), {
      'identityToken': 'identity-token',
      'authorizationCode': 'authorization-code',
      'nonce': 'raw-nonce',
      'platform': 'IOS',
      'email': 'user@example.com',
      'givenName': '현영',
      'familyName': '조',
    });
  });
}
