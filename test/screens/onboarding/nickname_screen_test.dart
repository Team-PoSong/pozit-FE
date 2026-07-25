import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/onboarding/nickname_screen.dart';

void main() {
  testWidgets('사용 가능한 닉네임을 입력하면 다음 단계 콜백을 호출한다', (tester) async {
    String? nickname;
    await tester.pumpWidget(
      MaterialApp(
        home: NicknameScreen(
          validationDelay: Duration.zero,
          onNext: (value) => nickname = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '윤지');
    await tester.pumpAndSettle();
    expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);

    await tester.tap(find.text('다음'));
    expect(nickname, '윤지');
  });

  testWidgets('중복 닉네임이면 오류를 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NicknameScreen(
          validationDelay: Duration.zero,
          validateNickname: (_) async => false,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '참새');
    await tester.pumpAndSettle();
    expect(find.text('이미 사용중인 아이디입니다.'), findsOneWidget);
  });

  testWidgets('키보드가 표시되어도 다음 버튼 위치를 유지한다', (tester) async {
    Widget buildScreen(double keyboardHeight) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(393, 852),
            padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 0 : 34),
            viewPadding: const EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: keyboardHeight),
          ),
          child: const NicknameScreen(),
        ),
      );
    }

    await tester.pumpWidget(buildScreen(0));
    final buttonTopBeforeKeyboard = tester.getTopLeft(find.text('다음')).dy;

    await tester.pumpWidget(buildScreen(300));
    await tester.pump();
    final buttonTopAfterKeyboard = tester.getTopLeft(find.text('다음')).dy;

    expect(buttonTopAfterKeyboard, buttonTopBeforeKeyboard);
  });
}
