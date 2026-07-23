import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_location.dart';

void main() {
  testWidgets('reorderIndex가 있으면 순서 변경 드래그 핸들을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLocation(
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            showReorderHandle: true,
            reorderIndex: 0,
          ),
        ),
      ),
    );

    expect(find.byType(ReorderableDragStartListener), findsOneWidget);
    expect(find.bySemanticsLabel('순서 변경'), findsOneWidget);
  });

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
    expect(find.bySemanticsLabel('더보기'), findsNothing);

    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(wasDeleted, isTrue);
    expect(find.text('삭제하기'), findsNothing);
  });

  testWidgets('글자를 확대해도 삭제 팝오버에서 오버플로우가 발생하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: AppLocation(
            name: '첨성대',
            address: '경북 경주시 인왕동 839-1',
            onDelete: _doNothing,
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('더보기'));
    await tester.pumpAndSettle();

    expect(find.text('삭제하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _doNothing() {}
