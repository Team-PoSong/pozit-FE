import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_travel_date_select.dart';
import 'package:pozit/core/design_system/widgets/button/app_button.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/screens/travel_creation/travel_schedule_screen.dart';

void main() {
  // 모든 생성 방식에서 3박 4일 허용 및 4박 5일 차단을 검증합니다.
  for (final TravelCreationMethod method in TravelCreationMethod.values) {
    testWidgets('${method.name}: 3박 4일까지 진행하고 초과 시 공통 안내를 표시한다', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      DateTimeRange? submittedRange;

      await tester.pumpWidget(
        MaterialApp(
          home: TravelScheduleScreen(
            destination: '경주',
            minimumDate: DateTime(2026, 7, 1),
            creationMethod: method,
            onNext: (DateTimeRange range) => submittedRange = range,
          ),
        ),
      );

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('13'));
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(find.byType(AppButton)).isEnabled, isTrue);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(submittedRange?.duration.inDays, 3);

      submittedRange = null;
      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      expect(find.text('아직 포짓에서는 3박 4일까지만 지원해요'), findsOneWidget);
      expect(find.textContaining('찜한 코스'), findsNothing);
      expect(tester.widget<AppButton>(find.byType(AppButton)).isEnabled, isFalse);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(submittedRange, isNull);

      await tester.tap(find.text('13'));
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(find.byType(AppButton)).isEnabled, isTrue);
      expect(find.text('아직 포짓에서는 3박 4일까지만 지원해요'), findsNothing);
    });
  }

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

  testWidgets('종료일 활성 상태에서 뒤 날짜를 누르면 종료일이 변경된다', (tester) async {
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
    expect(dateDisplay.startDate, DateTime(2026, 7, 10));
    expect(dateDisplay.endDate, DateTime(2026, 7, 15));
    expect(dateDisplay.activeSelection, AppTravelDateSelection.end);
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
