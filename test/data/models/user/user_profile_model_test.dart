import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/user/user_profile_model.dart';

void main() {
  test('내 정보 응답을 모델로 변환한다', () {
    final profile = UserProfileModel.fromJson({
      'userId': 1,
      'nickname': '민서',
      'socialProvider': 'KAKAO',
      'pushEnabled': true,
      'notiTravelEnabled': true,
      'notiGroupEnabled': false,
      'notiPozingEnabled': true,
      'notiCourseEnabled': false,
      'notiNoticeEnabled': true,
    });

    expect(profile.userId, 1);
    expect(profile.nickname, '민서');
    expect(profile.socialProvider, SocialProvider.kakao);
    expect(profile.notiGroupEnabled, isFalse);
  });

  test('지원하지 않는 소셜 제공자는 파싱하지 않는다', () {
    expect(
      () => SocialProvider.fromJson('NAVER'),
      throwsA(isA<FormatException>()),
    );
  });
}
