import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_course_bottom_sheet.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_location_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../data/models/travel_course_model.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import '../travel_detail/widgets/travel_status.dart';

// TravelDetailTopBar의 고정 높이(_kHeight)와 동일해야 합니다.
const double _kTopBarHeight = 56.0;
// 바텀 시트를 최대로 올렸을 때 탑 바와 남겨야 하는 간격입니다.
const double _kSheetTopGap = 15.0;

const double _kHorizontalPadding = 24.0;
const double _kHandleToDateDetailGap = 22.0;
const double _kDateDetailToCourseGap = 30.0;
const double _kLocationGap = 8.0;

/// 여행 상세 화면의 '코스 보기'에서 진입하는, 전체 화면 지도 위에 코스를
/// 보여주는 화면입니다.
///
/// 바탕 전체가 이동 가능한 지도이고, 그 위에 방문 상태를 보여주는 탑 바와
/// 일차별 코스를 보여주는 바텀 시트가 떠 있는 형태입니다. 지도의 원(마커)과
/// 바텀 시트의 장소 항목은 서로 선택 상태를 공유해서, 어느 한쪽을 누르면
/// 반대쪽도 함께 강조됩니다.
class TravelCourseMapScreen extends StatefulWidget {
  const TravelCourseMapScreen({
    super.key,
    required this.courses,
    required this.status,
    this.initialDay = 1,
    this.onBackTap,
  });

  /// 코스 목록입니다. 같은 [TravelCourseModel.dayNumber]를 가진 항목이 여러 개면
  /// touristSpotId 기준으로 하나의 동선으로 합쳐서 보여줍니다.
  final List<TravelCourseModel> courses;
  final AppTravelStatus status;
  final int initialDay;
  final VoidCallback? onBackTap;

  @override
  State<TravelCourseMapScreen> createState() => _TravelCourseMapScreenState();
}

class _TravelCourseMapScreenState extends State<TravelCourseMapScreen> {
  late int _selectedDay = widget.initialDay;

  /// 지도의 원과 바텀 시트의 장소 항목이 함께 공유하는 선택 상태입니다.
  int? _selectedSpotId;

  List<int> get _dayNumbers {
    final set = widget.courses.map((c) => c.dayNumber).toSet().toList()
      ..sort();
    return set;
  }

  int get _dayCount => _dayNumbers.isEmpty ? 1 : _dayNumbers.length;

  /// 선택된 일차에 해당하는 장소들을, touristSpotId 기준으로 중복 없이
  /// orderIndex 순서대로 모은 목록입니다.
  List<CourseSpotModel> get _spotsForSelectedDay {
    final dayNumbers = _dayNumbers;
    final dayIndex = _selectedDay - 1;
    if (dayIndex < 0 || dayIndex >= dayNumbers.length) return const [];
    final targetDayNumber = dayNumbers[dayIndex];

    final seenSpotIds = <int>{};
    final merged = <CourseSpotModel>[];
    for (final course in widget.courses.where(
      (c) => c.dayNumber == targetDayNumber,
    )) {
      final sorted = [...course.spots]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final spot in sorted) {
        if (seenSpotIds.add(spot.touristSpotId)) merged.add(spot);
      }
    }
    return merged;
  }

  List<MapMarker> _markersForSelectedDay() {
    // TravelStatusIndicator와 동일하게, '방문중' 개념은 여행이 실제로
    // 진행 중일 때만 존재합니다.
    final allowVisiting = widget.status == AppTravelStatus.inProgress;

    return [
      for (final spot in _spotsForSelectedDay)
        MapMarker(
          position: LatLng(spot.latitude, spot.longitude),
          label: spot.name,
          status: switch (spot.status) {
            'visited' => MapMarkerStatus.visited,
            'visiting' when allowVisiting => MapMarkerStatus.visiting,
            _ => MapMarkerStatus.notVisited,
          },
          isSelected: spot.touristSpotId == _selectedSpotId,
        ),
    ];
  }

  void _handleDayChanged(int day) {
    final clamped = day.clamp(1, _dayCount);
    if (clamped == _selectedDay) return;
    setState(() {
      _selectedDay = clamped;
      _selectedSpotId = null;
    });
  }

  void _handleLocationSelected(int touristSpotId, bool selected) {
    setState(() => _selectedSpotId = selected ? touristSpotId : null);
  }

  void _handleMarkerTap(int index) {
    final spots = _spotsForSelectedDay;
    if (index < 0 || index >= spots.length) return;
    final touristSpotId = spots[index].touristSpotId;
    setState(() {
      _selectedSpotId = _selectedSpotId == touristSpotId ? null : touristSpotId;
    });
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topInset = MediaQuery.of(context).padding.top;
    final maxChildSize =
        1 - (topInset + _kTopBarHeight + _kSheetTopGap) / screenHeight;

    final spots = _spotsForSelectedDay;
    final travelStatusMode = widget.status == AppTravelStatus.inProgress
        ? TravelStatusMode.traveling
        : TravelStatusMode.notTraveling;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapView(
              markers: _markersForSelectedDay(),
              onMarkerTap: _handleMarkerTap,
              enableGestures: true,
              // 바텀 시트가 기본으로 화면 아래쪽 일부를 가리고 있으므로,
              // 자동으로 카메라를 맞출 때 마커들이 가려지지 않는 위쪽
              // 영역 안에 들어오도록 합니다.
              fitVisibleFraction: 1 - AppCourseBottomSheet.defaultRestingExtent,
            ),
          ),
          AppCourseBottomSheet(
            showFloatingButton: false,
            maxChildSize: maxChildSize,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _kHandleToDateDetailGap),
                  AppDateDetailSelect(
                    dayCount: _dayCount,
                    selectedDay: _selectedDay,
                    onChanged: _handleDayChanged,
                  ),
                  const SizedBox(height: _kDateDetailToCourseGap),
                  for (var i = 0; i < spots.length; i++) ...[
                    if (i > 0) const SizedBox(height: _kLocationGap),
                    AppLocationSelect(
                      key: ValueKey(spots[i].touristSpotId),
                      title: spots[i].name,
                      address: spots[i].address,
                      showTrailingIndicator: false,
                      isSelected: spots[i].touristSpotId == _selectedSpotId,
                      onChanged: (selected) => _handleLocationSelected(
                        spots[i].touristSpotId,
                        selected,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // AppCourseBottomSheet가 화면 전체를 덮는 "바깥 탭하면 접기" 영역을
          // 가지고 있어서, 이보다 먼저(= 아래에) 쌓으면 탑 바가 그 뒤에 깔려
          // 뒤로가기 버튼이 한 번에 눌리지 않고 시트부터 접힙니다. 탑 바를
          // 맨 위에 쌓아 자기 영역만큼은 항상 먼저 히트테스트되게 합니다.
          SafeArea(
            bottom: false,
            child: TravelDetailTopBar(
              travelStatusMode: travelStatusMode,
              onBackTap: _handleBack,
            ),
          ),
        ],
      ),
    );
  }
}

List<TravelCourseModel> _previewCourses() {
  return [
    TravelCourseModel(
      courseId: 1,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: const [
        CourseSpotModel(
          courseSpotId: 1,
          touristSpotId: 1,
          name: '동궁과 월지',
          address: '경북 경주시 원화로 102',
          latitude: 35.8347,
          longitude: 129.2247,
          orderIndex: 0,
          status: 'visited',
        ),
        CourseSpotModel(
          courseSpotId: 2,
          touristSpotId: 2,
          name: '첨성대',
          address: '경북 경주시 인왕동 839-1',
          latitude: 35.8347,
          longitude: 129.2194,
          orderIndex: 1,
          status: 'visiting',
        ),
        CourseSpotModel(
          courseSpotId: 3,
          touristSpotId: 3,
          name: '대릉원',
          address: '경북 경주시 계림로 9',
          latitude: 35.8351,
          longitude: 129.2118,
          orderIndex: 2,
          status: 'notVisited',
        ),
      ],
    ),
    TravelCourseModel(
      courseId: 2,
      dayNumber: 2,
      date: DateTime(2026, 6, 6),
      spots: const [
        CourseSpotModel(
          courseSpotId: 4,
          touristSpotId: 4,
          name: '불국사',
          address: '경북 경주시 불국로 385',
          latitude: 35.7898,
          longitude: 129.3320,
          orderIndex: 0,
          status: 'notVisited',
        ),
        CourseSpotModel(
          courseSpotId: 5,
          touristSpotId: 5,
          name: '석굴암',
          address: '경북 경주시 석굴로 238',
          latitude: 35.7947,
          longitude: 129.3492,
          orderIndex: 1,
          status: 'notVisited',
        ),
      ],
    ),
  ];
}

@Preview(
  group: 'travel_course_map',
  name: 'TravelCourseMapScreen - 여행 중',
  size: Size(390, 844),
)
Widget travelCourseMapScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelCourseMapScreen(
      courses: _previewCourses(),
      status: AppTravelStatus.inProgress,
    ),
  );
}
