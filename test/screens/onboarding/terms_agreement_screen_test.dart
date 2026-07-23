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

  testWidgets('좁은 화면에서도 약관 보기 버튼을 표시하고 오버플로가 발생하지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TermsAgreementScreen()));

    expect(find.text('보기'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
