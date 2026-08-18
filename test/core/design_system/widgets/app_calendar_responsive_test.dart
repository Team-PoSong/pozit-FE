import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_calendar.dart';

void main() {
  const realisticWidths = [320.0, 360.0, 375.0, 390.0, 393.0, 412.0, 430.0, 600.0, 768.0];

  Future<void> pumpCalendarAt(
    WidgetTester tester,
    double width, {
    void Function(DateTime start, DateTime end)? onRangeSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: AppCalendar(
                initialMonth: DateTime(2026, 7),
                onRangeSelected: onRangeSelected ?? (start, end) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in realisticWidths) {
    testWidgets('width=$width: 오버플로우 없이 렌더링된다', (tester) async {
      await pumpCalendarAt(tester, width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('width=$width: 화살표 터치 영역은 48x48로 유지된다', (tester) async {
      await pumpCalendarAt(tester, width);

      final arrowFinder = find.byType(GestureDetector).first;
      final size = tester.getSize(arrowFinder);
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });

    testWidgets('width=$width: 날짜 셀 터치 영역 높이는 32로 유지되고 폭은 30 이상이다', (
      tester,
    ) async {
      await pumpCalendarAt(tester, width);

      final cellFinder = find.byType(GestureDetector).at(2);
      final size = tester.getSize(cellFinder);
      expect(size.height, 32.0);
      expect(size.width, greaterThanOrEqualTo(30.0));
    });

    testWidgets('width=$width: 날짜 셀 탭이 실제로 동작한다', (tester) async {
      DateTime? selectedStart;
      DateTime? selectedEnd;

      await pumpCalendarAt(
        tester,
        width,
        onRangeSelected: (start, end) {
          selectedStart = start;
          selectedEnd = end;
        },
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();

      expect(selectedStart, DateTime(2026, 7, 15));
      expect(selectedEnd, DateTime(2026, 7, 18));
    });
  }

  group('실사용 기기 범위 밖의 극단적으로 좁은 폭', () {
    for (final width in [180.0, 240.0]) {
      testWidgets('width=$width: 셀이 좁아지더라도 오버플로우 예외는 없다', (
        tester,
      ) async {
        await pumpCalendarAt(tester, width);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('큰 화면(태블릿)에서 셀이 디자인 상한(41px) 이상으로 커지지 않는다', (
    tester,
  ) async {
    await pumpCalendarAt(tester, 1024.0);

    final cellFinder = find.byType(GestureDetector).at(2);
    final size = tester.getSize(cellFinder);
    expect(size.width, lessThanOrEqualTo(41.0));
  });
}
