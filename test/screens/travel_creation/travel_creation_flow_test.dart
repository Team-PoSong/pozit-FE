import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_chip.dart';
import 'package:pozit/screens/likes/likes_screen.dart';
import 'package:pozit/screens/travel_creation/travel_creation_screen.dart';
import 'package:pozit/screens/travel_creation/travel_destination_screen.dart';
import 'package:pozit/screens/travel_creation/travel_schedule_screen.dart';

void main() {
  Future<void> pumpCreationScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TravelCreationScreen()));
  }

  testWidgets('추천 받기는 여행지 검색으로 이동한다', (tester) async {
    await pumpCreationScreen(tester);

    await tester.tap(find.text('추천 받기'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelDestinationScreen), findsOneWidget);
  });

  testWidgets('직접 만들기는 여행지 검색으로 이동한다', (tester) async {
    await pumpCreationScreen(tester);

    await tester.tap(find.text('직접 만들기'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelDestinationScreen), findsOneWidget);
  });

  testWidgets('찜한 코스는 기존 찜 목록으로 이동한다', (tester) async {
    await pumpCreationScreen(tester);

    await tester.ensureVisible(find.text('찜한 코스'));
    await tester.tap(find.text('찜한 코스'));
    await tester.pumpAndSettle();

    expect(find.byType(LikesScreen), findsOneWidget);
  });

  testWidgets('목 여행지를 검색·선택하고 다음을 누르면 날짜 선택으로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelDestinationScreen(
          onSearch: (_) async => const ['경상북도 경주시', '경상남도 경주시'],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '경주');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('경상북도 경주시'), findsOneWidget);
    expect(find.text('경상남도 경주시'), findsOneWidget);

    await tester.tap(find.text('경상북도 경주시'));
    await tester.pump();
    expect(find.byType(AppDeletableChip), findsOneWidget);
    expect(
      tester.widget<AppDeletableChip>(find.byType(AppDeletableChip)).label,
      '경상북도 경주시',
    );

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelScheduleScreen), findsOneWidget);
  });
}
