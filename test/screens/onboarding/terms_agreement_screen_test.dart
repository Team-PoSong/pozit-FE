import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/onboarding/terms_agreement_screen.dart';

void main() {
  testWidgets('전체 동의를 선택하면 모든 약관을 선택하고 다음 버튼을 활성화한다', (tester) async {
    var nextTapped = false;
    await tester.pumpWidget(
      MaterialApp(home: TermsAgreementScreen(onNext: () => nextTapped = true)),
    );

    expect(find.text('보기'), findsNWidgets(3));
    await tester.tap(find.text('모두 동의합니다'));
    await tester.pump();
    await tester.tap(find.text('다음'));

    expect(nextTapped, isTrue);
  });
}
