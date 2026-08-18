import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/mypage/nickname_edit_screen.dart';

void main() {
  testWidgets('서버 확인 전에는 사용 가능 문구를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NicknameEditScreen(initialNickname: '민서', onSubmit: (_) async {}),
      ),
    );

    await tester.enterText(find.byType(TextField), '서영');
    await tester.pump();

    expect(find.text('사용 가능한 닉네임입니다.'), findsNothing);
    expect(find.text('서영'), findsOneWidget);
  });
}
