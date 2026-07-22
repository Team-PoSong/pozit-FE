import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pozit/core/design_system/widgets/app_main_header.dart';

void main() {
  testWidgets('로고와 메인 헤더 액션을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppMainHeader())),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(3));
    expect(find.bySemanticsLabel('알림'), findsOneWidget);
    expect(find.bySemanticsLabel('찜 목록'), findsOneWidget);
    expect(find.bySemanticsLabel('마이페이지'), findsOneWidget);
    expect(tester.getSize(find.byType(AppMainHeader)), const Size(800, 40));
    expect(tester.getTopLeft(find.byType(Image)).dx, 21);
  });

  testWidgets('각 헤더 액션의 콜백을 호출한다', (tester) async {
    var notificationTapped = false;
    var wishTapped = false;
    var myPageTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMainHeader(
            onNotificationTap: () => notificationTapped = true,
            onWishTap: () => wishTapped = true,
            onMyPageTap: () => myPageTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('알림'));
    await tester.tap(find.bySemanticsLabel('찜 목록'));
    await tester.tap(find.bySemanticsLabel('마이페이지'));

    expect(notificationTapped, isTrue);
    expect(wishTapped, isTrue);
    expect(myPageTapped, isTrue);
  });
}
