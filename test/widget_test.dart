import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pozit/main.dart';

void main() {
  testWidgets('앱을 실행하면 로그인 화면을 표시한다', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('지금 포짓과 함께 여행을 떠나볼까요?'), findsOneWidget);
    expect(find.bySemanticsLabel('Apple로 로그인'), findsOneWidget);
    expect(find.bySemanticsLabel('카카오로 로그인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
