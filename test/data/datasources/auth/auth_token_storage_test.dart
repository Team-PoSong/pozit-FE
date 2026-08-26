import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/datasources/auth/auth_token_storage.dart';

void main() {
  const storage = FlutterSecureStorage();
  const tokenStorage = AuthTokenStorage(storage: storage);

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('새 로그인 응답에 refresh token이 없으면 이전 값을 삭제한다', () async {
    FlutterSecureStorage.setMockInitialValues({
      'pozit_refresh_token': 'previous-refresh-token',
    });

    await tokenStorage.save(
      accessToken: 'new-access-token',
      tokenType: 'Bearer',
      userId: 2,
    );

    expect(await tokenStorage.readRefreshToken(), isNull);
  });

  test('재발급에 사용한 refresh token이 현재 값과 같을 때만 저장한다', () async {
    FlutterSecureStorage.setMockInitialValues({
      'pozit_refresh_token': 'expected-refresh-token',
    });

    final saved = await tokenStorage.saveReissuedTokens(
      expectedRefreshToken: 'expected-refresh-token',
      accessToken: 'reissued-access-token',
      refreshToken: 'reissued-refresh-token',
    );

    expect(saved, isTrue);
    expect(await tokenStorage.readAccessToken(), 'reissued-access-token');
    expect(await tokenStorage.readRefreshToken(), 'reissued-refresh-token');
  });

  test('세션의 refresh token이 바뀌었으면 이전 재발급 결과를 폐기한다', () async {
    FlutterSecureStorage.setMockInitialValues({
      'pozit_access_token': 'current-access-token',
      'pozit_refresh_token': 'current-refresh-token',
    });

    final saved = await tokenStorage.saveReissuedTokens(
      expectedRefreshToken: 'old-refresh-token',
      accessToken: 'old-reissued-access-token',
      refreshToken: 'old-reissued-refresh-token',
    );

    expect(saved, isFalse);
    expect(await tokenStorage.readAccessToken(), 'current-access-token');
    expect(await tokenStorage.readRefreshToken(), 'current-refresh-token');
  });
}
