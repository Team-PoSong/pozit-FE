import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_chip.dart';
import 'package:pozit/screens/travel_creation/travel_info_screen.dart';

void main() {
  testWidgets('여행 태그는 최대 2개까지 선택하고 저장할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    TravelInfoResult? savedResult;
    await tester.pumpWidget(
      MaterialApp(
        home: TravelInfoScreen(
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

    await tester.tap(find.text('저장'));
    await tester.pump();
    expect(savedResult?.name, '포송한 여행');
    expect(savedResult?.tags, {'미식', '문화'});
  });
}
