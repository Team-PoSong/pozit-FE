import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/auth/login_screen.dart';

void main() {
  testWidgets('로그인 화면의 안내 문구와 소셜 로그인 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('지금 포짓과 함께 여행을 떠나볼까요?'), findsOneWidget);
    expect(find.text('여행의 순간을 남기는 가장 쉬운 방법'), findsOneWidget);
    expect(find.byKey(const Key('login-intro')), findsOneWidget);
    final guideBadgeSize = tester.getSize(
      find.byKey(const Key('login-guide-badge')),
    );
    expect(guideBadgeSize.width, greaterThanOrEqualTo(170));
    expect(guideBadgeSize.width, lessThan(300));
    expect(guideBadgeSize.height, 36);
    expect(find.bySemanticsLabel('Apple로 로그인'), findsOneWidget);
    expect(find.bySemanticsLabel('카카오로 로그인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('짧은 화면에서는 로그인 콘텐츠를 스크롤할 수 있다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.bySemanticsLabel('Apple로 로그인'), findsOneWidget);
    expect(find.bySemanticsLabel('카카오로 로그인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('로그인 처리 중 카카오 버튼을 연속으로 눌러도 한 번만 실행한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var loginCallCount = 0;
    final loginCompleter = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onKakaoLogin: () {
            loginCallCount++;
            return loginCompleter.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final kakaoButton = find.bySemanticsLabel('카카오로 로그인');
    await tester.tap(kakaoButton);
    await tester.tap(kakaoButton);

    expect(loginCallCount, 1);
    await tester.pump();
    expect(find.byKey(const Key('social-login-progress')), findsOneWidget);

    loginCompleter.complete();
    await tester.pump();
  });

  testWidgets('로그인 처리 중 Apple 버튼을 연속으로 눌러도 한 번만 실행한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var loginCallCount = 0;
    final loginCompleter = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onAppleLogin: () {
            loginCallCount++;
            return loginCompleter.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final appleButton = find.bySemanticsLabel('Apple로 로그인');
    await tester.tap(appleButton);
    await tester.tap(appleButton);

    expect(loginCallCount, 1);
    await tester.pump();
    expect(find.byKey(const Key('social-login-progress')), findsOneWidget);

    loginCompleter.complete();
    await tester.pump();
  });
}
