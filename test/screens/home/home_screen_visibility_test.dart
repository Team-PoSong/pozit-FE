import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_travel_card.dart';
import 'package:pozit/data/models/travel/active_course_spot_model.dart';
import 'package:pozit/data/models/travel/travel_list_model.dart';
import 'package:pozit/data/repositories/local/travel_store.dart';
import 'package:pozit/data/repositories/travel/travel_repository.dart';
import 'package:pozit/screens/home/home_screen.dart';

class _VisibilityTravelRepository extends TravelRepository {
  const _VisibilityTravelRepository();

  @override
  Future<List<ActiveCourseSpotModel>> getActiveCourseSpots() async => const [];

  @override
  Future<List<TravelListModel>> getTravels({required bool isDone}) async {
    if (!isDone) return const [];
    return [
      TravelListModel(
        travelId: 74,
        title: '공개 완료 여행',
        destination: '서울',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 2),
        status: AppTravelStatus.completed,
        isPublic: true,
        backgroundImageUrl: '',
        completionRate: 100,
        tags: const ['힐링'],
        leaderNickname: '현영',
        memberCount: 1,
        likeCount: 0,
      ),
    ];
  }
}

void main() {
  setUp(() => TravelStore.instance.travels.value = const []);
  tearDown(() => TravelStore.instance.travels.value = const []);

  testWidgets('완료 여행 목록 카드에 서버의 공개 상태를 반영한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(travelRepository: _VisibilityTravelRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('완료 1'));
    await tester.pumpAndSettle();

    final card = tester.widget<AppTravelCard>(find.byType(AppTravelCard));
    expect(card.isPublic, isTrue);
  });
}
