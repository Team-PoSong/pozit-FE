import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/auth/auth_token_storage.dart';
import 'package:pozit/data/models/auth/login_token_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('POZIT accessToken을 보안 저장소에 저장한다', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = AuthTokenStorage();
    await storage.save(accessToken: 'pozit-token', tokenType: 'Bearer');

    expect(await storage.readAccessToken(), 'pozit-token');
  });

  test('로그인 응답을 LoginTokenModel로 변환한다', () {
    final token = LoginTokenModel.fromJson({
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
