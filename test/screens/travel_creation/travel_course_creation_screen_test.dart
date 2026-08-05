import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_date_detail_select.dart';
import 'package:pozit/core/design_system/widgets/button/app_chatbot_button.dart';
import 'package:pozit/screens/travel_creation/travel_course_creation_screen.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';

void main() {
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
}
