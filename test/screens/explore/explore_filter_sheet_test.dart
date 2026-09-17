import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/explore/widgets/explore_filter_sheet.dart';

void main() {
  testWidgets('날짜를 한 번 선택하고 적용하면 하루 범위를 반환한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ExploreFilterResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<ExploreFilterResult>(
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: ExploreFilterSheet(
                        initialTab: ExploreFilterTab.date,
                        selectedRegion: null,
                        selectedDateRange: null,
                        selectedCategories: {},
                      ),
                    ),
                  ),
                );
              },
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('적용하기'));
    await tester.pumpAndSettle();
    expect(result?.dateRange, isNotNull);
    expect(result?.dateRange?.start.day, 10);
    expect(result?.dateRange?.start, result?.dateRange?.end);
  });
}
