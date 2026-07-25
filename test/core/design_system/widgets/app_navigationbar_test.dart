import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_dimensions.dart';
import 'package:pozit/core/design_system/widgets/app_navigationbar.dart';

void main() {
  testWidgets('하단 네비게이션 항목과 포송이 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppNavigationBar()),
      ),
    );

    expect(find.text('여행'), findsOneWidget);
    expect(find.text('탐색'), findsOneWidget);
    expect(find.bySemanticsLabel('포짓'), findsOneWidget);
    expect(find.bySemanticsLabel('여행'), findsOneWidget);
    expect(find.bySemanticsLabel('탐색'), findsOneWidget);
  });

  testWidgets('여행과 탐색 탭은 최소 터치 영역을 보장한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppNavigationBar()),
      ),
    );

    expect(
      tester.getSize(find.bySemanticsLabel('여행')).width,
      AppDimensions.minimumTapTargetSize,
    );
    expect(
      tester.getSize(find.bySemanticsLabel('탐색')).width,
      AppDimensions.minimumTapTargetSize,
    );
  });

  testWidgets('탐색 탭과 포송이 버튼 콜백을 호출한다', (tester) async {
    AppNavigationTab? changedTab;
    var posongTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppNavigationBar(
            onChanged: (tab) => changedTab = tab,
            onPosongTap: () => posongTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('탐색'));
    await tester.tap(find.bySemanticsLabel('포짓'));

    expect(changedTab, AppNavigationTab.explore);
    expect(posongTapped, isTrue);
  });

  testWidgets('기기 하단 안전 영역만큼 높이를 확장한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
          child: Scaffold(bottomNavigationBar: AppNavigationBar()),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppNavigationBar)).height, 107);
  });
}
