import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pozit/core/design_system/widgets/app_input_field.dart';

void main() {
  testWidgets('텍스트 입력창의 높이는 48이다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppInputField())),
    );

    expect(tester.getSize(find.byType(AppInputField)).height, 48);
  });

  testWidgets('글자 크기가 커지면 텍스트 입력창 높이도 늘어난다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(body: AppInputField()),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppInputField)).height, greaterThan(48));
  });
}
