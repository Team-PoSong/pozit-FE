import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'package:pozit/core/config/app_config.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/core/network/dio_client.dart';
import 'package:pozit/data/datasources/auth/auth_token_storage.dart';
import 'package:pozit/data/models/travel_course_model.dart';
import 'package:pozit/data/models/travel_info_card_model.dart';
import 'package:pozit/screens/auth/auth_gate.dart';
import 'package:pozit/screens/travel_detail/travel_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  assert(
    AppConfig.kakaoMapKey.isNotEmpty,
    'AppConfig.kakaoMapKey에 카카오맵 네이티브 앱 키를 채워주세요.',
  );
  await KakaoMapSdk.instance.initialize(AppConfig.kakaoMapKey);

  DioClient.instance.attachAccessTokenProvider(
    () => const AuthTokenStorage().readAccessToken(),
  );

  // TODO(임시): 지도 마커 연동을 실기로 확인하기 위한 임시 진입점입니다.
  // 확인이 끝나면 아래를 `runApp(const MyApp());`로 되돌려주세요.
  runApp(const _MapMarkerPreviewApp());
}

class _MapMarkerPreviewApp extends StatelessWidget {
  const _MapMarkerPreviewApp();

  @override
  Widget build(BuildContext context) {
    final info = TravelInfoCardModel(
      destination: '경주',
      startDate: DateTime(2026, 6, 5),
      endDate: DateTime(2026, 6, 6),
      companionCount: 3,
      tags: const ['기록', '미식'],
      visitedPlaceCount: 12,
      recordCount: 48,
      completionRate: 0.6,
    );

    // 같은 날짜의 코스 후보들은 "서로 다른 곳"이 아니라, 같은 권역을 도는
    // 서로 다른 동선(순서·범위)이어야 현실적입니다. 그래서 1일차는 전부
    // 경주 시내 역사 유적지구, 2일차는 전부 불국사·석굴암 권역으로
    // 묶었습니다.
    final courses = [
      // 1일차 코스 A — 동궁과 월지 → 첨성대 → 대릉원. visited/visiting/
      // notVisited 세 상태를 모두 포함합니다.
      TravelCourseModel(
        courseId: 1,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 1,
            touristSpotId: 1,
            name: '동궁과 월지',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 0,
            status: 'visited',
          ),
          CourseSpotModel(
            courseSpotId: 2,
            touristSpotId: 2,
            name: '첨성대',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'visiting',
          ),
          CourseSpotModel(
            courseSpotId: 3,
            touristSpotId: 3,
            name: '대릉원',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 2,
            status: 'notVisited',
          ),
        ],
      ),
      // 1일차 코스 B — 코스 A와 같은 세 장소를 반대 순서로 도는 동선.
      TravelCourseModel(
        courseId: 2,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 4,
            touristSpotId: 3,
            name: '대릉원',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 5,
            touristSpotId: 2,
            name: '첨성대',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 6,
            touristSpotId: 1,
            name: '동궁과 월지',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 2,
            status: 'notVisited',
          ),
        ],
      ),
      // 1일차 코스 C — 시간이 부족할 때를 위한 짧은 동선(첨성대만).
      // 같은 시내 권역이면서 여행지 1곳뿐인 경우(연결선 없음)를 확인합니다.
      TravelCourseModel(
        courseId: 3,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 7,
            touristSpotId: 2,
            name: '첨성대',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 0,
            status: 'notVisited',
          ),
        ],
      ),
      // 1일차 코스 D — 코스 A를 계림까지 확장한 4곳짜리 긴 동선.
      // orderIndex를 일부러 뒤섞어 정렬 로직도 같이 확인합니다.
      TravelCourseModel(
        courseId: 4,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 8,
            touristSpotId: 3,
            name: '대릉원',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 2,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 9,
            touristSpotId: 1,
            name: '동궁과 월지',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 10,
            touristSpotId: 2,
            name: '첨성대',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 11,
            touristSpotId: 6,
            name: '계림',
            latitude: 35.8345,
            longitude: 129.2159,
            orderIndex: 3,
            status: 'notVisited',
          ),
        ],
      ),
      // 2일차 코스 E — 불국사 → 석굴암.
      TravelCourseModel(
        courseId: 5,
        dayNumber: 2,
        date: DateTime(2026, 6, 6),
        spots: const [
          CourseSpotModel(
            courseSpotId: 12,
            touristSpotId: 9,
            name: '불국사',
            latitude: 35.7898,
            longitude: 129.3320,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 13,
            touristSpotId: 10,
            name: '석굴암',
            latitude: 35.7947,
            longitude: 129.3492,
            orderIndex: 1,
            status: 'notVisited',
          ),
        ],
      ),
      // 2일차 코스 F — 코스 E와 같은 두 곳을 반대 순서로 도는 동선.
      TravelCourseModel(
        courseId: 6,
        dayNumber: 2,
        date: DateTime(2026, 6, 6),
        spots: const [
          CourseSpotModel(
            courseSpotId: 14,
            touristSpotId: 10,
            name: '석굴암',
            latitude: 35.7947,
            longitude: 129.3492,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 15,
            touristSpotId: 9,
            name: '불국사',
            latitude: 35.7898,
            longitude: 129.3320,
            orderIndex: 1,
            status: 'notVisited',
          ),
        ],
      ),
      // 3일차 — 코스 1개, 여행지도 1곳뿐인 완전한 최소 케이스.
      TravelCourseModel(
        courseId: 7,
        dayNumber: 3,
        date: DateTime(2026, 6, 7),
        spots: const [
          CourseSpotModel(
            courseSpotId: 16,
            touristSpotId: 16,
            name: '보문관광단지',
            latitude: 35.8484,
            longitude: 129.2712,
            orderIndex: 0,
            status: 'notVisited',
          ),
        ],
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '지도 마커 연동 확인',
      home: TravelDetailScreen(
        info: info,
        status: AppTravelStatus.inProgress,
        courses: courses,
      ),
    );
  }
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
