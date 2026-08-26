class LoginTokenModel {
  const LoginTokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.nickname,
    required this.isNewUser,
  });

  factory LoginTokenModel.fromJson(Map<String, dynamic> json) {
    return LoginTokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final int userId;
  final String nickname;
  final bool isNewUser;
}
