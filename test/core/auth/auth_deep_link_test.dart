import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/auth/auth_deep_link.dart';

void main() {
  group('AuthDeepLink.loginCodeFrom', () {
    test('로그인 콜백에서 loginCode를 반환한다', () {
      final loginCode = AuthDeepLink.loginCodeFrom(
        Uri.parse('pozit://auth/callback?loginCode=test-code'),
      );

      expect(loginCode, 'test-code');
    });

    test('다른 딥링크는 무시한다', () {
      final loginCode = AuthDeepLink.loginCodeFrom(
        Uri.parse('pozit://travel/callback?loginCode=test-code'),
      );

      expect(loginCode, isNull);
    });

    test('loginCode가 비어 있으면 무시한다', () {
      final loginCode = AuthDeepLink.loginCodeFrom(
        Uri.parse('pozit://auth/callback?loginCode='),
      );

      expect(loginCode, isNull);
    });
  });
}
