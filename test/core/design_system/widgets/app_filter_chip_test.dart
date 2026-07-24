import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pozit/core/design_system/app_icons.dart';
import 'package:pozit/core/design_system/widgets/app_filter_chip.dart';

void main() {
  testWidgets('라벨 필터를 누르면 콜백을 호출한다', (tester) async {
    bool isTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFilterChip(label: '지역', onTap: () => isTapped = true),
        ),
      ),
    );

    await tester.tap(find.text('지역'));

    expect(isTapped, isTrue);
  });

  testWidgets('아이콘 전용 필터를 필터 초기화 버튼으로 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppFilterChip.icon(iconAsset: AppIcons.turnBack)),
      ),
    );

    expect(find.bySemanticsLabel('필터 초기화'), findsOneWidget);
  });
}
