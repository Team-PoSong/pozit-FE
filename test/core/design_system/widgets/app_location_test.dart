import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_location.dart';

void main() {
  testWidgets('더보기를 누르면 삭제 팝오버를 표시하고 삭제 콜백을 호출한다', (tester) async {
    bool wasDeleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppLocation(
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            showReorderHandle: true,
            onDelete: () => wasDeleted = true,
          ),
        ),
      ),
    );

    expect(find.text('삭제하기'), findsNothing);

    await tester.tap(find.bySemanticsLabel('더보기'));
    await tester.pumpAndSettle();

    expect(find.text('삭제하기'), findsOneWidget);

    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(wasDeleted, isTrue);
    expect(find.text('삭제하기'), findsNothing);
  });
}
