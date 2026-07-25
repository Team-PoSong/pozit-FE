import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pozit/screens/chatbot/chat_input_field.dart';

void main() {
  testWidgets('챗봇 입력창은 높이 48과 좌우 여백 20을 사용한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(width: 299, child: AppChatInputField())),
      ),
    );

    final inputRect = tester.getRect(find.byType(AppChatInputField));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppChatInputField),
        matching: find.byType(Container),
      ),
    );

    expect(inputRect.height, 48);
    expect(container.padding, const EdgeInsets.symmetric(horizontal: 20));
  });

  testWidgets('글자 크기가 커지면 챗봇 입력창 높이도 늘어난다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(
            body: SizedBox(width: 299, child: AppChatInputField()),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AppChatInputField)).height,
      greaterThan(48),
    );
  });
}
