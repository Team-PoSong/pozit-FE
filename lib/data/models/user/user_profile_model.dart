class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.nickname,
    required this.socialProvider,
    required this.pushEnabled,
    required this.notiTravelEnabled,
    required this.notiGroupEnabled,
    required this.notiPozingEnabled,
    required this.notiCourseEnabled,
    required this.notiNoticeEnabled,
  });

  final int userId;
  final String nickname;
  final SocialProvider socialProvider;
  final bool pushEnabled;
  final bool notiTravelEnabled;
  final bool notiGroupEnabled;
  final bool notiPozingEnabled;
  final bool notiCourseEnabled;
  final bool notiNoticeEnabled;

  UserProfileModel copyWith({
    int? userId,
    String? nickname,
    SocialProvider? socialProvider,
    bool? pushEnabled,
    bool? notiTravelEnabled,
    bool? notiGroupEnabled,
    bool? notiPozingEnabled,
    bool? notiCourseEnabled,
    bool? notiNoticeEnabled,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      socialProvider: socialProvider ?? this.socialProvider,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      notiTravelEnabled: notiTravelEnabled ?? this.notiTravelEnabled,
      notiGroupEnabled: notiGroupEnabled ?? this.notiGroupEnabled,
      notiPozingEnabled: notiPozingEnabled ?? this.notiPozingEnabled,
      notiCourseEnabled: notiCourseEnabled ?? this.notiCourseEnabled,
      notiNoticeEnabled: notiNoticeEnabled ?? this.notiNoticeEnabled,
    );
  }
}

enum SocialProvider {
  kakao,
  apple;

  String get label => switch (this) {
    SocialProvider.kakao => '카카오',
    SocialProvider.apple => 'Apple',
  };
}
