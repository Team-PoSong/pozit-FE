class AppleLoginRequest {
  const AppleLoginRequest({
    required this.identityToken,
    required this.authorizationCode,
    required this.nonce,
    required this.platform,
    this.email,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String authorizationCode;
  final String nonce;
  final String platform;
  final String? email;
  final String? givenName;
  final String? familyName;

  Map<String, dynamic> toJson() {
    return {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      'nonce': nonce,
      'platform': platform,
      if (email != null) 'email': email,
      if (givenName != null) 'givenName': givenName,
      if (familyName != null) 'familyName': familyName,
    };
  }
}
