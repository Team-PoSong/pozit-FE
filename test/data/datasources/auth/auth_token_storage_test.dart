import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/datasources/auth/auth_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('POZIT accessToken을 보안 저장소에 저장한다', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = AuthTokenStorage();
    await storage.save(accessToken: 'pozit-token', tokenType: 'Bearer');

    expect(await storage.readAccessToken(), 'pozit-token');
  });
}
