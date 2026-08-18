import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_images.dart';
import 'package:pozit/core/design_system/widgets/app_travel_card.dart';
import 'package:pozit/screens/explore/explore_screen.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/screens/travel_creation/travel_recommendation_loading_screen.dart';
import 'package:pozit/screens/travel_creation/travel_recommendation_result_screen.dart';

void main() {
  testWidgets('추천 준비 중 티켓 이미지가 떠 있고 응답 후 결과로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final completer = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: TravelRecommendationLoadingScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
            creationMethod: TravelCreationMethod.recommendation,
            transportation: '자동차',
            densityLevel: 2,
          ),
          loadRecommendations: () => completer.future,
        ),
      ),
    );

    expect(find.textContaining('추천 코스를 준비중'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, const AssetImage(AppImages.carrierTicket));

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(TravelRecommendationResultScreen), findsOneWidget);
    expect(find.byType(AppTravelCard), findsNWidgets(3));
    final browseOtherCourses = find.text('다른 사람 코스 둘러보기');
    expect(browseOtherCourses, findsOneWidget);

    await tester.ensureVisible(browseOtherCourses);
    await tester.tap(browseOtherCourses);
    await tester.pumpAndSettle();

    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(find.text('탐색'), findsOneWidget);
  });

  testWidgets('재시도 중에는 추천 요청을 중복 실행하지 않는다', (tester) async {
    var requestCount = 0;
    final retryCompleter = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: TravelRecommendationLoadingScreen(
          travelInfo: TravelInfoResult(
            destination: '경주',
            dateRange: DateTimeRange(
              start: DateTime(2026, 7, 3),
              end: DateTime(2026, 7, 6),
            ),
            name: '포송한 여행',
            tags: const {'미식'},
            creationMethod: TravelCreationMethod.recommendation,
            transportation: '자동차',
            densityLevel: 2,
          ),
          loadRecommendations: () {
            requestCount++;
            if (requestCount == 1) return Future<void>.error('load failed');
            return retryCompleter.future;
          },
        ),
      ),
    );
    await tester.pump();

    final retryButton = find.text('다시 시도하기');
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.tap(retryButton);
    expect(requestCount, 2);

    retryCompleter.complete();
    await tester.pumpAndSettle();
  });
}
