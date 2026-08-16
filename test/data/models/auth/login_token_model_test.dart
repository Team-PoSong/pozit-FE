import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/auth/login_token_model.dart';

void main() {
  test('로그인 응답에서 신규 회원 여부를 파싱한다', () {
    final token = LoginTokenModel.fromJson({
      'accessToken': 'access-token',
      'tokenType': 'Bearer',
      'expiresIn': 1800,
      'userId': 1,
      'nickname': '민서',
      'isNewUser': true,
    });

    expect(token.isNewUser, isTrue);
  });

  test('isNewUser가 누락되면 기존 회원으로 처리한다', () {
    final token = LoginTokenModel.fromJson({
      'accessToken': 'access-token',
      'tokenType': 'Bearer',
      'expiresIn': 1800,
      'userId': 1,
      'nickname': '민서',
    });

    expect(token.isNewUser, isFalse);
  });

  test('isNewUser가 null이면 기존 회원으로 처리한다', () {
    final token = LoginTokenModel.fromJson({
      'accessToken': 'access-token',
      'tokenType': 'Bearer',
      'expiresIn': 1800,
      'userId': 1,
      'nickname': '민서',
      'isNewUser': null,
    });

    expect(token.isNewUser, isFalse);
  });
}
