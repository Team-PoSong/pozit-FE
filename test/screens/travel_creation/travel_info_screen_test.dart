import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_chip.dart';
import 'package:pozit/core/design_system/widgets/button/app_button.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/screens/travel_creation/travel_course_creation_screen.dart';
import 'package:pozit/screens/travel_creation/travel_info_screen.dart';
import 'package:pozit/screens/travel_creation/travel_preferences_screen.dart';
import 'package:pozit/data/models/travel/travel_tag_model.dart';
import 'package:pozit/data/repositories/travel/travel_repository.dart';

class _TagRepository extends TravelRepository {
  const _TagRepository();

  @override
  Future<List<TravelTagModel>> getTags() async => const [
    TravelTagModel(id: 1, name: '미식'),
    TravelTagModel(id: 2, name: '문화'),
    TravelTagModel(id: 3, name: '힐링'),
    TravelTagModel(id: 4, name: '탐험'),
    TravelTagModel(id: 5, name: '기록'),
    TravelTagModel(id: 6, name: '체험'),
  ];
}

void main() {
  testWidgets('키보드가 나타나도 화면은 고정하고 다음 버튼까지 스크롤한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경주',
          dateRange: DateTimeRange(
            start: DateTime(2026, 8, 1),
            end: DateTime(2026, 8, 2),
          ),
        ),
      ),
    );
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.resizeToAvoidBottomInset, isFalse);

    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byKey(const Key('travel-info-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    final nextButton = find.byType(AppButton);
    await tester.ensureVisible(nextButton);
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(nextButton).dy, lessThanOrEqualTo(552));
  });

  testWidgets('찜한 코스의 태그는 미리 선택되어 있다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경주',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 4),
          ),
          creationMethod: TravelCreationMethod.wish,
          initialTags: const ['힐링', '미식'],
        ),
      ),
    );
    await tester.pump();

    final selectedLabels = tester
        .widgetList<AppTagChip>(find.byType(AppTagChip))
        .where((chip) => chip.isSelected)
        .map((chip) => chip.label);
    expect(selectedLabels, containsAll(['# 힐링', '# 미식']));
  });

  testWidgets('찜 초안의 태그 ID를 기준으로 선택 상태와 저장값을 복원한다', (tester) async {
    TravelInfoResult? savedResult;
    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경주',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 4),
          ),
          creationMethod: TravelCreationMethod.wish,
          initialTags: const ['서버에서 변경된 이름'],
          initialTagIds: const [3],
          onSave: (result) => savedResult = result,
        ),
      ),
    );
    await tester.pump();

    final selectedLabels = tester
        .widgetList<AppTagChip>(find.byType(AppTagChip))
        .where((chip) => chip.isSelected)
        .map((chip) => chip.label);
    expect(selectedLabels, ['# 힐링']);

    await tester.enterText(find.byType(TextField), '찜 기반 여행');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pump();
    expect(savedResult?.tagIds, [3]);
    expect(savedResult?.tags, {'힐링'});
  });

  testWidgets('여행 태그는 최대 2개까지 선택하고 저장할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    TravelInfoResult? savedResult;
    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경상북도 경주시',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 5),
          ),
          onSave: (result) => savedResult = result,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '포송한 여행');
    await tester.tap(find.text('# 미식'));
    await tester.tap(find.text('# 문화'));
    await tester.tap(find.text('# 힐링'));
    await tester.pump();

    final selectedChips = tester
        .widgetList<AppTagChip>(find.byType(AppTagChip))
        .where((chip) => chip.isSelected)
        .toList();
    expect(selectedChips.length, 2);
    expect(selectedChips.map((chip) => chip.label), ['# 미식', '# 문화']);

    await tester.tap(find.text('다음'));
    await tester.pump();
    expect(savedResult?.name, '포송한 여행');
    expect(savedResult?.tags, {'미식', '문화'});
  });

  testWidgets('여행 정보를 저장하면 코스 구성 화면으로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경주',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 5),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '포송한 여행');
    await tester.tap(find.text('# 미식'));
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelCourseCreationScreen), findsOneWidget);
  });

  testWidgets('추천 받기는 여행 정보 다음에 이동수단과 스타일을 선택한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
          repository: const _TagRepository(),
          destination: '경주',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 5),
          ),
          creationMethod: TravelCreationMethod.recommendation,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '포송한 여행');
    await tester.tap(find.text('# 미식'));
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelPreferencesScreen), findsOneWidget);
  });
}
