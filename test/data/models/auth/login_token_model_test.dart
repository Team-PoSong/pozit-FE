import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/auth/login_token_model.dart';

void main() {
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
