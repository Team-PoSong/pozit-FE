import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_search_bar.dart';

void main() {
  testWidgets('검색창의 높이는 48이다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppSearchBar())),
    );

    expect(tester.getSize(find.byType(AppSearchBar)).height, 48);
  });

  testWidgets('키보드 검색 완료 시 검색어를 전달한다', (tester) async {
    String? submittedQuery;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchBar(onSubmitted: (query) => submittedQuery = query),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '경주');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    expect(submittedQuery, '경주');
  });

  testWidgets('글자 크기가 커지면 검색창 높이도 늘어난다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(body: AppSearchBar()),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppSearchBar)).height, greaterThan(48));
  });
}
