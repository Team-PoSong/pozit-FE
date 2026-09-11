import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_date_detail_select.dart';
import 'package:pozit/core/design_system/widgets/app_location_select.dart';
import 'package:pozit/core/design_system/widgets/app_location.dart';
import 'package:pozit/core/design_system/widgets/button/app_button.dart';
import 'package:pozit/core/design_system/widgets/button/app_circle_button.dart';
import 'package:pozit/screens/course_edit/course_edit_screen.dart';
import 'package:pozit/screens/location_search/location_search_screen.dart';
import 'package:pozit/screens/travel_creation/travel_course_creation_screen.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';
import 'package:pozit/data/models/tourist_spot_search_result_model.dart';
import 'package:pozit/data/models/tourist_spot_model.dart';
import 'package:pozit/data/models/tourist_spot_rank_model.dart';
import 'package:pozit/data/repositories/tourist_spot/tourist_spot_repository.dart';

class _TouristSpotRepository extends TouristSpotRepository {
  const _TouristSpotRepository();

  static const spots = [
    TouristSpotModel(
      touristSpotId: 1,
      name: '불국사',
      address: '경북 경주시',
      latitude: 35.79,
      longitude: 129.33,
    ),
    TouristSpotModel(
      touristSpotId: 2,
      name: '미륵사지',
      address: '전북 익산시',
      latitude: 35.98,
      longitude: 126.99,
    ),
    TouristSpotModel(
      touristSpotId: 3,
      name: '경주월드',
      address: '경북 경주시',
      latitude: 35.83,
      longitude: 129.28,
    ),
  ];

  @override
  Future<TouristSpotRankPage> getHostTouristSpotsRank({
    String? regionCode,
    int cursor = 1,
  }) async => TouristSpotRankPage(
    ranks: [
      for (var index = 0; index < spots.length; index++)
        TouristSpotRankModel(
          rank: index + 1,
          touristSpotId: spots[index].touristSpotId,
          title: spots[index].name,
          address: spots[index].address,
          latitude: spots[index].latitude,
          longitude: spots[index].longitude,
          courseSpotCount: 1,
        ),
    ],
    currentCursor: cursor,
    nextCursor: null,
    hasNext: false,
  );

  @override
  Future<List<TouristSpotModel>> saveSelectedSpots(
    List<TouristSpotSearchResultModel> selected,
  ) async => [
    for (final selectedSpot in selected)
      TouristSpotModel(
        touristSpotId: int.parse(selectedSpot.contentId),
        name: selectedSpot.title,
        address: selectedSpot.address,
        latitude: selectedSpot.latitude,
        longitude: selectedSpot.longitude,
      ),
  ];
}

void main() {
  testWidgets('새 일정이 짧으면 초과 일차를 버리고 길면 뒤 일차를 비워둔다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final originalCourses = List.generate(4, _courseForDay);
    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 8, 1),
              end: DateTime(2026, 8, 5),
            ),
            name: '긴 여행',
            tags: const {'힐링'},
            creationMethod: TravelCreationMethod.wish,
            initialCourses: originalCourses,
          ),
        ),
      ),
    );

    expect(find.text('5일차'), findsOneWidget);
    final fifthDayButton = find
        .descendant(
          of: find.byType(AppDateDetailSelect),
          matching: find.byType(GestureDetector),
        )
        .last;
    await tester.tap(fifthDayButton);
    await tester.pumpAndSettle();
    expect(find.text('5일차'), findsNWidgets(2));
    expect(find.byType(AppLocation), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 8, 1),
              end: DateTime(2026, 8, 3),
            ),
            name: '짧은 여행',
            tags: const {'힐링'},
            creationMethod: TravelCreationMethod.wish,
            initialCourses: originalCourses,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4일차'), findsNothing);
    final firstDayButton = find
        .descendant(
          of: find.byType(AppDateDetailSelect),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.tap(firstDayButton);
    await tester.pumpAndSettle();
    expect(find.text('1일차 장소'), findsOneWidget);
  });

  testWidgets('찜한 코스의 장소가 코스 구성 화면에 유지된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 4),
            ),
            name: '가져온 여행',
            tags: const {'힐링'},
            creationMethod: TravelCreationMethod.wish,
            initialCourses: [
              TravelCourseModel(
                courseId: 10,
                dayNumber: 1,
                date: DateTime(2026, 6, 5),
                spots: const [
                  CourseSpotModel(
                    courseSpotId: 20,
                    touristSpotId: 30,
                    name: '첨성대',
                    address: '경북 경주시 인왕동 839-1',
                    latitude: 35.8347,
                    longitude: 129.2194,
                    orderIndex: 0,
                    status: 'visited',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('첨성대'), findsOneWidget);
    expect(find.text('경북 경주시 인왕동 839-1'), findsOneWidget);
  });

  testWidgets('선택한 일차와 굵은 제목이 같이 변경된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
          ),
        ),
      ),
    );

    expect(find.byType(AppDateDetailSelect), findsOneWidget);
    expect(find.text('1일차'), findsNWidgets(2));

    final daySelector = find.byType(AppDateDetailSelect);
    final selectorTopLeft = tester.getTopLeft(daySelector);
    final selectorSize = tester.getSize(daySelector);
    await tester.tapAt(
      selectorTopLeft + Offset(selectorSize.width * 0.875, 15),
    );
    await tester.pumpAndSettle();
    expect(find.text('4일차'), findsNWidgets(2));
  });

  testWidgets('플러스 버튼을 누르면 API 장소 검색 화면으로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          touristSpotRepository: const _TouristSpotRepository(),
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppCircleButton));
    await tester.pumpAndSettle();

    expect(find.byType(LocationSearchScreen), findsOneWidget);
    expect(find.text('장소 검색'), findsOneWidget);
    expect(find.text('지금 인기 있는 장소'), findsOneWidget);
    expect(find.text('불국사'), findsOneWidget);
    expect(find.text('미륵사지'), findsOneWidget);
    expect(find.text('경주월드'), findsOneWidget);
  });

  testWidgets('장소를 선택해 추가하면 선택한 일차의 코스가 갱신된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          touristSpotRepository: const _TouristSpotRepository(),
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppCircleButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppLocationSelect, '불국사'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 추가하기'));
    await tester.pumpAndSettle();

    expect(find.byType(LocationSearchScreen), findsNothing);
    expect(find.text('1일차 코스'), findsOneWidget);
    expect(find.byType(AppLocation), findsOneWidget);
    expect(find.text('불국사'), findsOneWidget);
  });

  testWidgets('검색어를 수정하면 인기 장소가 숨고 전부 지우면 다시 나타난다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelCourseCreationScreen(
          touristSpotRepository: const _TouristSpotRepository(),
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppCircleButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '불');
    await tester.pump();
    expect(find.text('지금 인기 있는 장소'), findsNothing);
    expect(find.text('불국사'), findsNothing);

    await tester.enterText(find.byType(EditableText), '');
    await tester.pump();
    expect(find.text('지금 인기 있는 장소'), findsOneWidget);
    expect(find.text('불국사'), findsOneWidget);
  });

  testWidgets('검색 중 검색어를 바꾸면 이전 검색 응답을 무시한다', (tester) async {
    final firstSearch = Completer<TouristSpotSearchPage>();

    await tester.pumpWidget(
      MaterialApp(
        home: LocationSearchScreen(
          onSearch: (query, cursor) => firstSearch.future,
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '강릉');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '경주');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    firstSearch.complete(
      const TouristSpotSearchPage(
        places: [
          TouristSpotSearchResultModel(
            contentId: '1',
            contentTypeId: '12',
            title: '강릉 이전 결과',
            address: '강릉시',
            latitude: 37.7,
            longitude: 128.8,
          ),
        ],
        currentCursor: 1,
        nextCursor: null,
        hasNext: false,
      ),
    );
    await tester.pump();

    expect(find.text('강릉 이전 결과'), findsNothing);
    expect(find.text('검색 결과가 없어요.'), findsNothing);
  });

  testWidgets('좁은 화면과 큰 글씨에서도 검색 안내와 출처가 겹치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: LocationSearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '불');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('두 글자 이상 검색할 수 있어요.'), findsOneWidget);
    expect(find.text('출처 : © 한국관광콘텐츠랩'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('추천 코스 저장 중에는 시스템 뒤로가기로 화면을 종료하지 않는다', (tester) async {
    final saveCompleter = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: CourseEditScreen(
          courses: [_courseForDay(0)],
          isCreationFlow: true,
          onSave: (_) => saveCompleter.future,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(AppButton, '여행 시작하기'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(CourseEditScreen), findsOneWidget);
    saveCompleter.complete();
    await tester.pumpAndSettle();
  });
}

TravelCourseModel _courseForDay(int zeroBasedDay) {
  final day = zeroBasedDay + 1;
  return TravelCourseModel(
    courseId: day,
    dayNumber: day,
    date: DateTime(2026, 7, day),
    spots: [
      CourseSpotModel(
        courseSpotId: day,
        touristSpotId: day,
        name: '$day일차 장소',
        address: '$day일차 주소',
        latitude: 35,
        longitude: 129,
        orderIndex: 0,
        status: 'notVisited',
      ),
    ],
  );
}
