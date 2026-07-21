import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/auth/auth_token_storage.dart';
import 'package:pozit/core/auth/login_token.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('POZIT accessToken을 보안 저장소에 저장한다', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = AuthTokenStorage();
    const token = LoginToken(
      accessToken: 'pozit-token',
      tokenType: 'Bearer',
      expiresIn: 1800000,
      userId: 3,
      nickname: '조현영',
    );

    await storage.save(token);

    expect(await storage.readAccessToken(), 'pozit-token');
  });

  test('로그인 응답을 LoginToken으로 변환한다', () {
    final token = LoginToken.fromJson({
      'accessToken': 'pozit-token',
      'tokenType': 'Bearer',
      'expiresIn': 1800000,
      'userId': 3,
      'nickname': '조현영',
    });

    expect(token.accessToken, 'pozit-token');
    expect(token.tokenType, 'Bearer');
    expect(token.expiresIn, 1800000);
    expect(token.userId, 3);
    expect(token.nickname, '조현영');
  });
}
