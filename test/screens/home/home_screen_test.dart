import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pozit/core/design_system/widgets/app_main_header.dart';
import 'package:pozit/core/design_system/widgets/app_top_navigate_bar.dart';
import 'package:pozit/screens/home/home_screen.dart';

void main() {
  testWidgets('홈 화면의 헤더, 여행 탭, 추가 버튼과 빈 상태를 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(AppMainHeader), findsOneWidget);
    expect(tester.getTopLeft(find.byType(AppMainHeader)).dy, 60);
    expect(tester.getTopLeft(find.byType(AppTopNavigateBar)).dy, 120);
    expect(find.byType(AppTopNavigateBar), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(4));
    expect(find.text('여행이 없어요! 포짓과 함께 떠나볼까요?'), findsOneWidget);
    expect(find.bySemanticsLabel('여행 만들기'), findsOneWidget);
  });

  testWidgets('여행 만들기 버튼 콜백을 호출한다', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(onCreateTravelTap: () => tapped = true)),
    );

    await tester.tap(find.bySemanticsLabel('여행 만들기'));

    expect(tapped, isTrue);
  });
}
