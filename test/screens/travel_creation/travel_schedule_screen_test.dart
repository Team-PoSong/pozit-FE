import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_travel_date_select.dart';
import 'package:pozit/screens/travel_creation/travel_schedule_screen.dart';

void main() {
  testWidgets('초기 날짜는 비어 있고 시작일 선택 후 종료일이 활성화된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    var dateDisplay = tester.widget<AppTravelDate>(find.byType(AppTravelDate));
    expect(dateDisplay.startDate, isNull);
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    dateDisplay = tester.widget<AppTravelDate>(find.byType(AppTravelDate));
    expect(dateDisplay.startDate, DateTime(2026, 7, 10));
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.end);
    expect(find.text('7월 10일'), findsOneWidget);
  });

  testWidgets('시작일 활성 상태에서 같은 날이나 이후를 누르면 전체 선택이 해제된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    final startDateButton = find
        .descendant(
          of: find.byType(AppTravelDate),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.tap(startDateButton);
    await tester.pumpAndSettle();

    var dateDisplay = tester.widget<AppTravelDate>(find.byType(AppTravelDate));
    expect(dateDisplay.startDate, DateTime(2026, 7, 10));
    expect(dateDisplay.endDate, DateTime(2026, 7, 12));
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    dateDisplay = tester.widget<AppTravelDate>(find.byType(AppTravelDate));
    expect(dateDisplay.startDate, isNull);
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);
  });

  testWidgets('종료일로 시작일보다 앞 날짜를 누르면 전체 선택이 해제된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    final dateDisplay = tester.widget<AppTravelDate>(
      find.byType(AppTravelDate),
    );
    expect(dateDisplay.startDate, isNull);
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);
  });

  testWidgets('시작일 활성 상태에서 앞 날짜를 누르면 시작일만 변경된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    final startDateButton = find
        .descendant(
          of: find.byType(AppTravelDate),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.tap(startDateButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    final dateDisplay = tester.widget<AppTravelDate>(
      find.byType(AppTravelDate),
    );
    expect(dateDisplay.startDate, DateTime(2026, 7, 8));
    expect(dateDisplay.endDate, DateTime(2026, 7, 12));
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);
  });

  testWidgets('종료일 활성 상태에서 뒤 날짜를 누르면 전체 선택이 해제된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    final dateDisplay = tester.widget<AppTravelDate>(
      find.byType(AppTravelDate),
    );
    expect(dateDisplay.startDate, isNull);
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);
  });

  testWidgets('종료일 활성 상태에서 같은 날이나 이전을 누르면 전체 선택이 해제된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelScheduleScreen(
          destination: '경주',
          minimumDate: DateTime(2026, 7, 1),
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    final dateDisplay = tester.widget<AppTravelDate>(
      find.byType(AppTravelDate),
    );
    expect(dateDisplay.startDate, isNull);
    expect(dateDisplay.endDate, isNull);
    expect(dateDisplay.activeSelection, AppTravelDateSelection.start);
  });
}
