class LoginToken {
  const LoginToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.nickname,
  });

  factory LoginToken.fromJson(Map<String, dynamic> json) {
    return LoginToken(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
    );
  }

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final int userId;
  final String nickname;
}
