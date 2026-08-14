import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/onboarding/nickname_screen.dart';

void main() {
  testWidgets('서버 저장 전에는 사용 가능 문구를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: NicknameScreen(onNext: (_) async {})),
    );

    await tester.enterText(find.byType(TextField), '민서');
    await tester.pump();

    expect(find.text('사용 가능한 닉네임입니다.'), findsNothing);
  });
}
