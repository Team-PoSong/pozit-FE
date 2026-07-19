import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/design_system/widgets/app_date_detail_select.dart';

void main() {
  testWidgets('dayCount가 줄어들면 선택 일차를 새 범위로 보정한다', (tester) async {
    var dayCount = 4;
    var changedDays = <int>[];
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, stateSetter) {
            setState = stateSetter;
            return AppDateDetailSelect(
              dayCount: dayCount,
              onChanged: changedDays.add,
            );
          },
        ),
      ),
    );

    final fourthDayButton = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == '4일차',
    );
    await tester.tap(fourthDayButton);
    await tester.pumpAndSettle();
    changedDays = <int>[];

    setState(() => dayCount = 2);
    await tester.pumpAndSettle();

    final selectedText = tester.widget<Text>(find.text('2일차'));
    expect(selectedText.style?.color, AppColors.white);
    expect(changedDays, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
