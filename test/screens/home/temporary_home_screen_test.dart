import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/home/temporary_home_screen.dart';

void main() {
  testWidgets('로그인 성공 후 표시할 임시 홈 화면을 렌더링한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TemporaryHomeScreen()));

    expect(find.text('로그인 성공'), findsOneWidget);
    expect(find.text('홈 화면 연결 예정'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
