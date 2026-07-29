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

const double _kTopBarHeight = 60.0;

const double _kSheetTopGap = 15.0;

const double _kHorizontalPadding = 24.0;
const double _kHandleToDateDetailGap = 22.0;
const double _kDateDetailToCourseGap = 30.0;
const double _kLocationGap = 8.0;

class TravelCourseMapScreen extends StatefulWidget {
  const TravelCourseMapScreen({
    super.key,
    required this.courses,
    required this.status,
    required this.totalDays,
    this.initialDay = 1,
    this.onBackTap,
  });

  final List<TravelCourseModel> courses;
  final AppTravelStatus status;
  final int totalDays;
  final int initialDay;
  final VoidCallback? onBackTap;

  @override
  State<TravelCourseMapScreen> createState() => _TravelCourseMapScreenState();
}

class _TravelCourseMapScreenState extends State<TravelCourseMapScreen> {
  late int _selectedDay = widget.initialDay;

  int? _selectedSpotId;

  int get _dayCount => widget.totalDays;

  List<CourseSpotModel> get _spotsForSelectedDay {
    final seenSpotIds = <int>{};
    final merged = <CourseSpotModel>[];
    for (final course in widget.courses.where(
      (c) => c.dayNumber == _selectedDay,
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
      totalDays: 2,
    ),
  );
}
