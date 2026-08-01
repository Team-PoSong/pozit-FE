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
import 'package:pozit/data/models/travel_member_model.dart';
import 'package:pozit/data/models/tourist_spot_model.dart';
import 'package:pozit/screens/auth/auth_gate.dart';
import 'package:pozit/screens/course_edit/course_edit_screen.dart';
import 'package:pozit/screens/travel_course_map/travel_course_map_screen.dart';
import 'package:pozit/screens/travel_detail/travel_detail_screen.dart';
import 'package:pozit/screens/travel_log/travel_log_complete_screen.dart';
import 'package:pozit/screens/travel_log/travel_log_saving_screen.dart';
import 'package:pozit/screens/travel_member/travel_member_screen.dart';
import 'package:pozit/screens/travel_settings/travel_settings_screen.dart';

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

  runApp(const _MapMarkerPreviewApp());
}

class _MapMarkerPreviewApp extends StatelessWidget {
  const _MapMarkerPreviewApp();

  static const bool _isLeader = true;

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

    final courses = [
      TravelCourseModel(
        courseId: 1,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 1,
            touristSpotId: 1,
            name: '동궁과 월지',
            address: '경북 경주시 원화로 102',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 0,
            status: 'visited',
          ),
          CourseSpotModel(
            courseSpotId: 2,
            touristSpotId: 2,
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'visiting',
          ),
          CourseSpotModel(
            courseSpotId: 3,
            touristSpotId: 3,
            name: '대릉원',
            address: '경북 경주시 계림로 9',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 2,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 2,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 4,
            touristSpotId: 3,
            name: '대릉원',
            address: '경북 경주시 계림로 9',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 5,
            touristSpotId: 2,
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 6,
            touristSpotId: 1,
            name: '동궁과 월지',
            address: '경북 경주시 원화로 102',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 2,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 3,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 7,
            touristSpotId: 2,
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 0,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 4,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: const [
          CourseSpotModel(
            courseSpotId: 8,
            touristSpotId: 3,
            name: '대릉원',
            address: '경북 경주시 계림로 9',
            latitude: 35.8351,
            longitude: 129.2118,
            orderIndex: 2,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 9,
            touristSpotId: 1,
            name: '동궁과 월지',
            address: '경북 경주시 원화로 102',
            latitude: 35.8347,
            longitude: 129.2247,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 10,
            touristSpotId: 2,
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            latitude: 35.8347,
            longitude: 129.2194,
            orderIndex: 1,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 11,
            touristSpotId: 6,
            name: '계림',
            address: '경북 경주시 교동 1',
            latitude: 35.8345,
            longitude: 129.2159,
            orderIndex: 3,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 5,
        dayNumber: 2,
        date: DateTime(2026, 6, 6),
        spots: const [
          CourseSpotModel(
            courseSpotId: 12,
            touristSpotId: 9,
            name: '불국사',
            address: '경북 경주시 불국로 385',
            latitude: 35.7898,
            longitude: 129.3320,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 13,
            touristSpotId: 10,
            name: '석굴암',
            address: '경북 경주시 석굴로 238',
            latitude: 35.7947,
            longitude: 129.3492,
            orderIndex: 1,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 6,
        dayNumber: 2,
        date: DateTime(2026, 6, 6),
        spots: const [
          CourseSpotModel(
            courseSpotId: 14,
            touristSpotId: 10,
            name: '석굴암',
            address: '경북 경주시 석굴로 238',
            latitude: 35.7947,
            longitude: 129.3492,
            orderIndex: 0,
            status: 'notVisited',
          ),
          CourseSpotModel(
            courseSpotId: 15,
            touristSpotId: 9,
            name: '불국사',
            address: '경북 경주시 불국로 385',
            latitude: 35.7898,
            longitude: 129.3320,
            orderIndex: 1,
            status: 'notVisited',
          ),
        ],
      ),

      TravelCourseModel(
        courseId: 7,
        dayNumber: 3,
        date: DateTime(2026, 6, 7),
        spots: const [
          CourseSpotModel(
            courseSpotId: 16,
            touristSpotId: 16,
            name: '보문관광단지',
            address: '경북 경주시 보문로 132',
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
      home: Builder(
        builder: (context) => TravelDetailScreen(
          info: info,
          status: AppTravelStatus.upcoming,
          isLeader: _isLeader,
          courses: courses,
          onSettingsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TravelSettingsScreen(
                  status: AppTravelStatus.upcoming,
                  destination: info.destination,
                  initialTravelName: '${info.destination} 여행',
                  initialStartDate: info.startDate,
                  initialEndDate: info.endDate,
                  initialTags: info.tags,
                  onSave: (result) {
                    debugPrint(
                      '여행 설정 저장: ${result.travelName}, '
                      '${result.startDate}~${result.endDate}, '
                      '${result.tags}, 공개=${result.isPublic}',
                    );
                  },
                ),
              ),
            );
          },
          onCourseEditTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CourseEditScreen(
                  courses: courses,
                  popularSpots: const [
                    TouristSpotModel(
                      touristSpotId: 20,
                      name: '경주월드',
                      address: '경북 경주시 보문로 400-1',
                      latitude: 35.8402,
                      longitude: 129.2646,
                    ),
                    TouristSpotModel(
                      touristSpotId: 21,
                      name: '황리단길',
                      address: '경북 경주시 포석로 1080',
                      latitude: 35.8367,
                      longitude: 129.2103,
                    ),
                  ],
                  onSearch: (query) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    return const [
                      TouristSpotModel(
                        touristSpotId: 20,
                        name: '경주월드',
                        address: '경북 경주시 보문로 400-1',
                        latitude: 35.8402,
                        longitude: 129.2646,
                      ),
                    ].where((spot) => spot.name.contains(query)).toList();
                  },
                  onSave: (spotsByDay) {
                    debugPrint('코스 수정 저장: $spotsByDay');
                  },
                ),
              ),
            );
          },
          onMemberTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TravelMemberScreen(
                  isLeader: _isLeader,
                  status: AppTravelStatus.upcoming,
                  inviteCode: 'AB12C',
                  members: const [
                    TravelMemberModel(nickname: '김윤지', isLeader: true),
                    TravelMemberModel(nickname: '박서현', isLeader: false),
                  ],
                ),
              ),
            );
          },
          onLeaveTap: () => debugPrint('여행 나가기 확정'),
          onDeleteTap: () => debugPrint('여행 삭제 확정'),
          onCourseTap: (day) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TravelCourseMapScreen(
                  courses: courses,
                  status: AppTravelStatus.upcoming,
                  initialDay: day,
                  totalDays: info.totalDays,
                ),
              ),
            );
          },
          onSaveLogTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (routeContext) {
                  // TODO(travel-log): replace this fixed delay with the real
                  // local-save flow once it's implemented; for now it just
                  // demos the loading -> complete transition.
                  Future.delayed(const Duration(seconds: 2), () {
                    if (!routeContext.mounted) return;
                    Navigator.of(routeContext).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (completeContext) => TravelLogCompleteScreen(
                          travelName: '${info.destination} 여행',
                          onCancelTap: () =>
                              Navigator.of(completeContext).pop(),
                        ),
                      ),
                    );
                  });
                  return TravelLogSavingScreen(
                    travelName: '${info.destination} 여행',
                  );
                },
              ),
            );
          },
        ),
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
