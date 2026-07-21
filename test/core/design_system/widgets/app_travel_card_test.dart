import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_travel_card.dart';

void main() {
  testWidgets('다른 사용자 여행에는 status가 전달돼도 상태 배지를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTravelCard(
            type: AppTravelCardType.otherTravel,
            title: '경주 여행',
            location: '경주',
            dateText: '2026. 7. 20.',
            author: '포송이',
            status: AppTravelStatus.upcoming,
            dDay: 'D-3',
          ),
        ),
      ),
    );

    expect(find.text('D-3'), findsNothing);
  });
}
