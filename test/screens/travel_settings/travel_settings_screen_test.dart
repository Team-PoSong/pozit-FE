import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/core/design_system/widgets/toggle/app_visibility_toggle.dart';
import 'package:pozit/data/models/travel/travel_tag_model.dart';
import 'package:pozit/screens/travel_settings/travel_settings_screen.dart';

void main() {
  testWidgets('공개 설정 저장이 완료된 후 화면을 닫는다', (tester) async {
    final saveCompleter = Completer<bool>();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => TravelSettingsScreen(
                  status: AppTravelStatus.completed,
                  destination: '서울',
                  tagOptions: const [TravelTagModel(id: 1, name: '힐링')],
                  initialTravelName: '서울 여행',
                  initialStartDate: DateTime(2026, 8, 1),
                  initialEndDate: DateTime(2026, 8, 2),
                  initialTagIds: const [1],
                  onSave: (_) => saveCompleter.future,
                ),
              ),
            ),
            child: const Text('설정 열기'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('설정 열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('공개'));
    await tester.pump();
    await tester.ensureVisible(find.text('저장하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장하기'));
    await tester.pump();

    expect(find.byType(TravelSettingsScreen), findsOneWidget);
    expect(find.text('저장 중...'), findsOneWidget);
    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const ValueKey('travel-settings-saving-guard')),
          )
          .ignoring,
      isTrue,
    );

    final toggles = tester.widgetList<AppVisibilityToggle>(
      find.byType(AppVisibilityToggle),
    );
    expect(
      toggles.singleWhere((toggle) => toggle.label == '공개').isSelected,
      isTrue,
    );
    expect(
      toggles.singleWhere((toggle) => toggle.label == '비공개').isSelected,
      isFalse,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TravelSettingsScreen), findsOneWidget);

    saveCompleter.complete(true);
    await tester.pumpAndSettle();

    expect(find.byType(TravelSettingsScreen), findsNothing);
  });

  testWidgets('저장 실패 시 입력값을 유지하고 설정 화면에 남는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TravelSettingsScreen(
          status: AppTravelStatus.completed,
          destination: '서울',
          tagOptions: const [TravelTagModel(id: 1, name: '힐링')],
          initialTravelName: '서울 여행',
          initialStartDate: DateTime(2026, 8, 1),
          initialEndDate: DateTime(2026, 8, 2),
          initialTagIds: const [1],
          onSave: (_) async => false,
        ),
      ),
    );

    await tester.tap(find.text('공개'));
    await tester.ensureVisible(find.text('저장하기'));
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(find.byType(TravelSettingsScreen), findsOneWidget);
    final toggles = tester.widgetList<AppVisibilityToggle>(
      find.byType(AppVisibilityToggle),
    );
    expect(
      toggles.singleWhere((toggle) => toggle.label == '공개').isSelected,
      isTrue,
    );
  });
}
