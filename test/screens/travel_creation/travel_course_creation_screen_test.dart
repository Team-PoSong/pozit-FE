import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_date_detail_select.dart';
import 'package:pozit/core/design_system/widgets/app_location_select.dart';
import 'package:pozit/core/design_system/widgets/app_location.dart';
import 'package:pozit/core/design_system/widgets/button/app_chatbot_button.dart';
import 'package:pozit/core/design_system/widgets/button/app_circle_button.dart';
import 'package:pozit/screens/location_search/location_search_screen.dart';
import 'package:pozit/screens/travel_creation/travel_course_creation_screen.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';

void main() {
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
    expect(find.byType(AppChatbotButton), findsOneWidget);
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

  testWidgets('플러스 버튼을 누르면 목데이터가 있는 장소 검색 화면으로 이동한다', (tester) async {
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
}
