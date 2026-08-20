import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/widgets/app_chip.dart';
import 'package:pozit/core/design_system/widgets/button/app_button.dart';
import 'package:pozit/core/design_system/widgets/progress/app_density_track.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/screens/travel_creation/travel_preferences_screen.dart';
import 'package:pozit/screens/travel_creation/travel_recommendation_loading_screen.dart';

void main() {
  TravelInfoResult travelInfo() => TravelInfoResult(
    destination: '경주',
    dateRange: DateTimeRange(
      start: DateTime(2026, 7, 3),
      end: DateTime(2026, 7, 6),
    ),
    name: '포송한 여행',
    tags: const {'미식'},
    creationMethod: TravelCreationMethod.recommendation,
  );

  testWidgets('여행 스타일은 가운데가 기본이고 이동수단을 선택하면 다음으로 이동한다', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: TravelPreferencesScreen(travelInfo: travelInfo())),
    );

    expect(find.text('이동 수단을 알려주세요.'), findsOneWidget);
    expect(find.byType(AppDensityTrack), findsOneWidget);
    expect(
      tester.widget<AppDensityTrack>(find.byType(AppDensityTrack)).selectedIndex,
      1,
    );

    tester
        .widgetList<AppTagChip>(find.byType(AppTagChip))
        .firstWhere((chip) => chip.label == '자동차')
        .onTap!();
    await tester.pump();
    expect(tester.widget<AppButton>(find.byType(AppButton)).isEnabled, isTrue);
    await tester.tap(find.text('다음'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TravelRecommendationLoadingScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
  });
}
