import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'package:pozit/core/auth/auth_token_storage.dart';
import 'package:pozit/core/config/app_config.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/network/dio_client.dart';
import 'package:pozit/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  DioClient.instance.attachAccessTokenProvider(
    const AuthTokenStorage().readAccessToken,
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
      home: const LoginScreen(),
    );
  }
}
