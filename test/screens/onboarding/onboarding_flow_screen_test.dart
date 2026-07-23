import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/home/home_screen.dart';
import 'package:pozit/screens/onboarding/nickname_screen.dart';
import 'package:pozit/screens/onboarding/onboarding_flow_screen.dart';
import 'package:pozit/screens/onboarding/terms_agreement_screen.dart';

void main() {
  testWidgets('닉네임과 약관 동의를 완료하면 홈 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingFlowScreen()));

    expect(find.byType(NicknameScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), '포송');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byType(TermsAgreementScreen), findsOneWidget);

    await tester.tap(find.text('모두 동의합니다'));
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
