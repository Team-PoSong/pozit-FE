import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/core/design_system/widgets/app_navigationbar.dart';
import 'package:pozit/data/models/saved_travel_model.dart';
import 'package:pozit/data/models/travel/active_course_spot_model.dart';
import 'package:pozit/data/models/travel/travel_info_card_model.dart';
import 'package:pozit/data/repositories/local/travel_store.dart';
import 'package:pozit/data/repositories/travel/travel_repository.dart';
import 'package:pozit/screens/home/home_screen.dart';

class _NoActiveSpotsTravelRepository extends TravelRepository {
  const _NoActiveSpotsTravelRepository();

  @override
  Future<List<ActiveCourseSpotModel>> getActiveCourseSpots() async => const [];
}

SavedTravelModel _travel(int index) {
  final startDate = DateTime(2026, 9, 1).add(Duration(days: index));
  final endDate = startDate.add(const Duration(days: 1));
  return SavedTravelModel(
    id: 'travel-$index',
    title: '더미 여행 $index',
    location: '서울 종로',
    dateText: '${startDate.month}/${startDate.day} ~ ${endDate.month}/${endDate.day}',
    author: '포송',
    info: TravelInfoCardModel(
      destination: '서울 종로',
      startDate: startDate,
      endDate: endDate,
      companionCount: 2,
      visitedPlaceCount: 0,
      recordCount: 0,
      completionRate: 0,
    ),
    courses: const [],
    status: AppTravelStatus.upcoming,
    dDay: 'D-$index',
  );
}

Future<void> _pumpHomeScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(bottom: 34);
  addTearDown(tester.view.reset);

  for (var i = 0; i < 20; i++) {
    TravelStore.instance.save(_travel(i));
  }

  await tester.pumpWidget(
    const MaterialApp(
      home: HomeScreen(travelRepository: _NoActiveSpotsTravelRepository()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TravelStore.instance.travels.value = const [];
  });

  tearDown(() {
    TravelStore.instance.travels.value = const [];
  });

  testWidgets('여행 목록의 하단 패딩은 플로팅 바텀 네비게이션 바 높이만큼 확보되어 있다', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);

    final tripList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );
    final listView = tester.widget<ListView>(tripList);
    final padding = listView.padding as EdgeInsets?;

    final context = tester.element(tripList);
    final expectedClearance = AppNavigationBar.clearance(context);

    expect(
      padding?.bottom,
      expectedClearance,
      reason:
          '여행 목록 하단 패딩이 플로팅 네비게이션 바의 높이(핸들 영역 포함)보다 작으면 '
          '마지막 카드가 바에 가려질 수 있습니다.',
    );
  });

  testWidgets('여행이 많아도 목록을 끝까지 스크롤하면 마지막 카드가 바텀 네비게이션 바 위로 온전히 보인다', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);
    final lastTitle = TravelStore.instance.travels.value.last.title;

    final tripList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );
    final scrollable = find.descendant(
      of: tripList,
      matching: find.byType(Scrollable),
    );
    final scrollableState = tester.state<ScrollableState>(scrollable.first);

    // 실제로 끝까지 스크롤했을 때(=더 이상 스크롤할 수 없는 지점) 상태를 확인합니다.
    scrollableState.position.jumpTo(scrollableState.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text(lastTitle),
      findsOneWidget,
      reason: '스크롤을 끝까지 내리면 마지막 여행 카드가 화면에 렌더링되어야 합니다.',
    );

    final lastCardBottom = tester.getBottomLeft(find.text(lastTitle)).dy;
    final navBarTop = tester.getTopLeft(find.byType(AppNavigationBar)).dy;

    expect(
      lastCardBottom,
      lessThanOrEqualTo(navBarTop),
      reason: '마지막 여행 카드가 플로팅 바텀 네비게이션 바에 가려지면 안 됩니다.',
    );
  });

  testWidgets('미완료/완료 토글과 + 버튼은 목록 레이아웃 공간을 차지하는 형제 위젯이며, 목록과의 사이에 고정 여백이 있다', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);

    final tripList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );
    final menuButtonFinder = find.bySemanticsLabel('여행 메뉴 열기');

    // 토글/버튼이 목록 레이아웃을 밀어내는 형제 위젯이라면 목록 뷰포트는
    // 토글/버튼 아래, 즉 화면 상단보다 아래에서 시작합니다.
    final listViewportTop = tester.getTopLeft(tripList).dy;
    final menuButtonTop = tester.getTopLeft(menuButtonFinder).dy;

    expect(
      listViewportTop,
      greaterThan(menuButtonTop),
      reason:
          '토글/버튼이 목록 레이아웃 공간을 차지하는 형제 위젯이라면 목록 뷰포트는 '
          '토글/버튼보다 아래에서 시작해야 합니다.',
    );

    final gapBeforeScroll =
        listViewportTop - tester.getBottomLeft(menuButtonFinder).dy;
    expect(
      gapBeforeScroll,
      greaterThan(0),
      reason:
          '목록 첫 카드가 토글/+ 버튼 바로 아래에 붙지 않도록 고정 여백이 있어야 합니다.',
    );

    // 목록을 스크롤해도 토글/버튼과 목록 사이의 고정 여백은 그대로 유지되어야 합니다
    // (여백이 스크롤되는 ListView 패딩이 아니라 레이아웃에 고정된 위젯이기 때문입니다).
    final scrollable = find.descendant(
      of: tripList,
      matching: find.byType(Scrollable),
    );
    final scrollableState = tester.state<ScrollableState>(scrollable.first);

    scrollableState.position.jumpTo(300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(tripList).dy,
      listViewportTop,
      reason: '목록을 스크롤해도 토글/버튼과 목록 뷰포트 사이의 고정 여백은 그대로 유지되어야 합니다.',
    );
  });
}
