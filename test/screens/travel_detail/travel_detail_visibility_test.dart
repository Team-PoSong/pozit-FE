import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel/travel_info_card_model.dart';
import 'package:pozit/screens/travel_detail/travel_detail_screen.dart';
import 'package:pozit/screens/travel_detail/widgets/travel_detail_top_bar.dart';

TravelDetailScreen _screen({
  required AppTravelStatus status,
  required bool isPublic,
}) {
  return TravelDetailScreen(
    title: '서울 여행',
    info: TravelInfoCardModel(
      destination: '서울',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 2),
      companionCount: 1,
      visitedPlaceCount: 0,
      recordCount: 0,
      completionRate: 0,
    ),
    status: status,
    isLeader: true,
    isPublic: isPublic,
    isMyTravel: status == AppTravelStatus.completed,
  );
}

void main() {
  testWidgets('완료 여행 상세는 공개 여부와 관계없이 자물쇠를 표시한다', (tester) async {
    for (final isPublic in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: _screen(status: AppTravelStatus.completed, isPublic: isPublic),
        ),
      );

      final topBar = tester.widget<TravelDetailTopBar>(
        find.byType(TravelDetailTopBar),
      );
      expect(topBar.showLock, isTrue);
      expect(topBar.isPublic, isPublic);
    }
  });

  testWidgets('여행 중 상세는 자물쇠를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _screen(status: AppTravelStatus.inProgress, isPublic: false),
      ),
    );

    final topBar = tester.widget<TravelDetailTopBar>(
      find.byType(TravelDetailTopBar),
    );
    expect(topBar.showLock, isFalse);
  });
}
