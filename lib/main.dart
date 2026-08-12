import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'package:pozit/core/config/app_config.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/network/dio_client.dart';
import 'package:pozit/data/datasources/auth/auth_token_storage.dart';
import 'package:pozit/data/datasources/auth/kakao_login_service.dart';
import 'package:pozit/data/repositories/auth/auth_repository.dart';
import 'package:pozit/screens/auth/login_screen.dart';
import 'package:pozit/screens/travel_detail/travel_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  assert(
    AppConfig.kakaoMapKey.isNotEmpty,
    'AppConfig.kakaoMapKey에 카카오맵 네이티브 앱 키를 채워주세요.',
  );
  try {
    await KakaoMapSdk.instance.initialize(AppConfig.kakaoMapKey);
  } catch (error) {
    debugPrint('KakaoMapSdk 초기화 실패: $error');
  }

  DioClient.instance.attachAccessTokenProvider(
    () => const AuthTokenStorage().readAccessToken(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pozit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Pretendard',
      ),
      home: const _TravelDetailLoginEntry(),
    );
  }
}

class _TravelDetailLoginEntry extends StatelessWidget {
  const _TravelDetailLoginEntry();

  Future<void> _loginAndOpenDetail(BuildContext context) async {
    final accessToken = await const KakaoLoginService().login();
    await AuthRepository().loginWithKakaoAccessToken(accessToken);
    if (!context.mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const TravelDetailPage(travelId: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(onKakaoLogin: () => _loginAndOpenDetail(context));
  }
}
