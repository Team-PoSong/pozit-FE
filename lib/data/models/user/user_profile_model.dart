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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      socialProvider: SocialProvider.fromJson(json['socialProvider'] as String),
      pushEnabled: json['pushEnabled'] as bool,
      notiTravelEnabled: json['notiTravelEnabled'] as bool,
      notiGroupEnabled: json['notiGroupEnabled'] as bool,
      notiPozingEnabled: json['notiPozingEnabled'] as bool,
      notiCourseEnabled: json['notiCourseEnabled'] as bool,
      notiNoticeEnabled: json['notiNoticeEnabled'] as bool,
    );
  }

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

  factory SocialProvider.fromJson(String value) {
    return switch (value) {
      'KAKAO' => SocialProvider.kakao,
      'APPLE' => SocialProvider.apple,
      _ => throw FormatException('지원하지 않는 소셜 로그인 제공자입니다: $value'),
    };
  }
}
