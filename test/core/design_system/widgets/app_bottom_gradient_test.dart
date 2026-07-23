import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_bottom_gradient.dart';

void main() {
  testWidgets('화면 너비와 지정 높이만큼 하단 그라데이션을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppBottomGradient())),
    );

    expect(
      tester.getSize(find.byType(AppBottomGradient)),
      const Size(800, AppBottomGradient.height),
    );
  });
}
