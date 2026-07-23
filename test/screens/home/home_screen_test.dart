import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pozit/core/design_system/widgets/app_bottom_gradient.dart';
import 'package:pozit/core/design_system/widgets/app_main_header.dart';
import 'package:pozit/core/design_system/widgets/app_navigationbar.dart';
import 'package:pozit/screens/home/home_screen.dart';
import 'package:pozit/screens/home/widgets/travel_completion_toggle.dart';

void main() {
  testWidgets('홈 화면의 헤더, 여행 탭, 추가 버튼과 빈 상태를 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(AppMainHeader), findsOneWidget);
    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.byType(AppBottomGradient), findsOneWidget);
    expect(tester.getTopLeft(find.byType(AppMainHeader)).dy, 0);
    expect(tester.getTopLeft(find.byType(TravelCompletionToggle)).dy, 64);
    expect(find.byType(TravelCompletionToggle), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(4));
    expect(find.text('여행이 없어요! 포짓과 함께 떠나볼까요?'), findsOneWidget);
    expect(find.bySemanticsLabel('여행 메뉴 열기'), findsOneWidget);
  });

  testWidgets('여행 메뉴를 열고 여행 만들기 콜백을 호출한다', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(onCreateTravelTap: () => tapped = true)),
    );

    await tester.tap(find.bySemanticsLabel('여행 메뉴 열기'));
    await tester.pumpAndSettle();

    expect(find.text('여행 만들기'), findsOneWidget);
    expect(find.text('초대코드로 참여하기'), findsOneWidget);
    expect(find.bySemanticsLabel('여행 메뉴 닫기'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('travel-menu-popover'))),
      const Size(205, 114),
    );
    final menuButtonRect = tester.getRect(find.bySemanticsLabel('여행 메뉴 닫기'));
    final popoverRect = tester.getRect(
      find.byKey(const ValueKey('travel-menu-popover')),
    );
    expect(popoverRect.right, menuButtonRect.right);
    expect(popoverRect.top - menuButtonRect.bottom, 10);

    await tester.tap(find.text('여행 만들기'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('여행 만들기'), findsNothing);
  });

  testWidgets('여행 메뉴 바깥을 누르면 메뉴를 닫는다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.bySemanticsLabel('여행 메뉴 열기'));
    await tester.pumpAndSettle();
    expect(find.text('여행 만들기'), findsOneWidget);

    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();

    expect(find.text('여행 만들기'), findsNothing);
    expect(find.bySemanticsLabel('여행 메뉴 열기'), findsOneWidget);
  });
}
