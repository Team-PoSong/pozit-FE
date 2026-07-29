class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://api.pozit.kr';

  static const String kakaoNativeAppKey = 'e8fc6abad12e9b55dbf73798fe65c140';

  static const String kakaoMapKey = 'e8fc6abad12e9b55dbf73798fe65c140';

  static const String appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
    defaultValue: 'kr.pozit.app.login',
  );

  static const String appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: 'https://api.pozit.kr/api/auth/apple/callback',
  );
}
