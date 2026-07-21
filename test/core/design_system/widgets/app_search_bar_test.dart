import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_search_bar.dart';

void main() {
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
}
