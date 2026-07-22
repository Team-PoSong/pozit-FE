import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/auth/kakao_login_service.dart';

void main() {
  test('카카오톡이 설치되면 앱 로그인만 시도한다', () async {
    var accountLoginCallCount = 0;
    final service = KakaoLoginService(
      isTalkInstalled: () async => true,
      loginWithTalk: () async => throw StateError('앱 로그인 실패'),
      loginWithAccount: () async {
        accountLoginCallCount++;
        return 'account-token';
      },
    );

    await expectLater(service.login(), throwsStateError);
    expect(accountLoginCallCount, 0);
  });

  test('카카오톡이 없을 때만 카카오계정 로그인을 시도한다', () async {
    final service = KakaoLoginService(
      isTalkInstalled: () async => false,
      loginWithTalk: () async => 'talk-token',
      loginWithAccount: () async => 'account-token',
    );

    expect(await service.login(), 'account-token');
  });

  test('사용자가 앱 로그인을 취소하면 취소 예외로 변환한다', () async {
    final service = KakaoLoginService(
      isTalkInstalled: () async => true,
      loginWithTalk: () async => throw PlatformException(code: 'CANCELED'),
    );

    await expectLater(
      service.login(),
      throwsA(isA<KakaoLoginCanceledException>()),
    );
  });
}
