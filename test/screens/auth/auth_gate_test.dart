import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/network/api_exception.dart';
import 'package:pozit/screens/auth/auth_gate.dart';

void main() {
  testWidgets('저장된 토큰이 없으면 로그인 화면을 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthGate(readAccessToken: () async => null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('지금 포짓과 함께 여행을 떠나볼까요?'), findsOneWidget);
  });

  testWidgets('유효한 토큰이 있으면 홈 화면을 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          readAccessToken: () async => 'pozit-token',
          validateSession: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('로그인 성공'), findsOneWidget);
  });

  testWidgets('만료된 토큰은 삭제하고 로그인 화면을 표시한다', (tester) async {
    var tokenCleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          readAccessToken: () async => 'expired-token',
          clearToken: () async {
            tokenCleared = true;
          },
          validateSession: () async =>
              throw const ApiException('인증이 필요합니다.', statusCode: 401),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tokenCleared, isTrue);
    expect(find.text('지금 포짓과 함께 여행을 떠나볼까요?'), findsOneWidget);
  });

  testWidgets('일시적 오류 후 재시도에 성공하면 홈 화면을 표시한다', (tester) async {
    var validationCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          readAccessToken: () async => 'pozit-token',
          retryDelay: Duration.zero,
          validateSession: () async {
            validationCount++;
            if (validationCount < 3) {
              throw const ApiException('네트워크 연결을 확인해 주세요.');
            }
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(validationCount, 3);
    expect(find.text('로그인 성공'), findsOneWidget);
  });

  testWidgets('세션 확인이 세 번 실패하면 토큰을 삭제하고 로그인 화면을 표시한다', (tester) async {
    var validationCount = 0;
    var tokenCleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          readAccessToken: () async => 'pozit-token',
          clearToken: () async {
            tokenCleared = true;
          },
          retryDelay: Duration.zero,
          validateSession: () async {
            validationCount++;
            throw const ApiException('네트워크 연결을 확인해 주세요.');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(validationCount, 3);
    expect(tokenCleared, isTrue);
    expect(find.text('지금 포짓과 함께 여행을 떠나볼까요?'), findsOneWidget);
    expect(find.text('로그인 상태를 확인하지 못했어요. 다시 로그인해 주세요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsNothing);
  });
}
