import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'package:pozit/core/config/app_config.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/network/dio_client.dart';
import 'package:pozit/data/datasources/auth/auth_token_storage.dart';
import 'package:pozit/data/mock/mock_saved_travels.dart';
import 'package:pozit/data/repositories/local/travel_store.dart';
import 'package:pozit/screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // 홈 화면 바텀 네비게이션 바 플로팅 동작을 스크롤로 확인하기 위한 더미 데이터입니다.
    for (final travel in buildMockSavedTravels()) {
      TravelStore.instance.save(travel);
    }
  }

  await KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  assert(
    AppConfig.kakaoMapKey.isNotEmpty,
    'AppConfig.kakaoMapKey에 카카오맵 네이티브 앱 키를 채워주세요.',
  );
  try {
    await KakaoMapSdk.instance.initialize(AppConfig.kakaoMapKey);
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'KakaoMapSdk initialization',
      ),
    );
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
      home: const AuthGate(),
    );
  }
}
