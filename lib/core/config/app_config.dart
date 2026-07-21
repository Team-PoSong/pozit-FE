class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://api.pozit.kr';

  static const String kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: 'e8fc6abad12e9b55dbf73798fe65c140',
  );
}
