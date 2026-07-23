import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_map_card.dart';

void main() {
  testWidgets('지도와 인디케이터의 하단 간격을 유지한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 345, child: AppMapCard(title: '연꽃단지')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          ((widget.decoration! as BoxDecoration).boxShadow?.isNotEmpty ??
              false),
    );
    final cardRect = tester.getRect(cardFinder.first);
    final imageRect = tester.getRect(find.byType(Image).first);
    final dotFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.constraints?.minWidth == 8 &&
          widget.constraints?.minHeight == 8 &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    final dotRect = tester.getRect(dotFinder.first);

    expect(dotRect.top - imageRect.bottom, 10);
    expect(cardRect.bottom - dotRect.bottom, 12);
  });
}
