import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_region_select.dart';

void main() {
  testWidgets('지역 선택 카드는 시안 크기와 텍스트 여백을 유지한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 345,
              child: AppRegionSelect(label: '경상북도 경주시'),
            ),
          ),
        ),
      ),
    );

    final card = find.byType(AppRegionSelect);
    final label = find.text('경상북도 경주시');
    expect(tester.getSize(card), const Size(345, 77));
    expect(tester.getTopLeft(label).dx - tester.getTopLeft(card).dx, 30);
  });
}
