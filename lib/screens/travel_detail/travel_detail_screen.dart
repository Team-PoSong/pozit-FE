import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../data/models/travel_course_model.dart';
import '../../data/models/travel_info_card_model.dart';
import 'widgets/travel_detail_bottom_section.dart';
import 'widgets/travel_detail_top_bar.dart';
import 'widgets/travel_info_card.dart';
import 'widgets/travel_status.dart';

const double _kPhotoHeight = 290.0;
const double _kHorizontalPadding = 24.0;
const double _kTopBarToInfoCardGap = 38.0;
const double _kPhotoToDateSelectGap = 17.0;
const double _kDateSelectToMapCardGap = 10.0;
const double _kMapCardToStatusGap = 8.0;
// 지도 카드를 좌우로 스와이프해, 선택된 일차 안에서 다음/이전 코스로
// 넘길 때 판정하는 최소 속도입니다.
const double _kSwipeVelocityThreshold = 200.0;

/// 여행 상세 화면입니다.
///
/// 여행의 진행 상태([status])에 따라 하단 영역이 달라지며, 자세한 내용은
/// [TravelDetailBottomSection]을 참고하세요.
class TravelDetailScreen extends StatefulWidget {
  const TravelDetailScreen({
    super.key,
    required this.info,
    required this.status,
    this.courses = const [],
    this.backgroundImage = const AssetImage(AppImages.travelMockup),
    this.initialDay = 1,
    this.onBackTap,
    this.onSettingsTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
    this.onCourseTap,
    this.onDayChanged,
    this.onSaveLogTap,
  });

  final TravelInfoCardModel info;
  final AppTravelStatus status;

  /// 코스 목록입니다. 같은 [TravelCourseModel.dayNumber]를 가진 항목이 여러 개일
  /// 수 있으며(하루에 코스 후보가 여럿인 경우), 그 경우 지도 카드를 좌우로
  /// 스와이프해 같은 일차 안에서 다음/이전 코스로 넘어갈 수 있습니다. 일차
  /// 자체는 [AppDateDetailSelect] 탭으로만 바뀝니다.
  final List<TravelCourseModel> courses;
  final ImageProvider<Object> backgroundImage;
  final int initialDay;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCourseTap;
  final ValueChanged<int>? onDayChanged;
  final VoidCallback? onSaveLogTap;

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> {
  late int _selectedDay = widget.initialDay;

  // 선택된 일차 안에서 몇 번째 코스를 보고 있는지입니다. 일차가 바뀌면 0으로
  // 초기화됩니다.
  int _selectedCourseIndex = 0;

  /// 코스가 가진 dayNumber를 오름차순으로 중복 제거한 목록입니다. 실제
  /// dayNumber 값(0부터 시작하는지 등)에 의존하지 않고, 이 목록에서의
  /// 위치(index + 1)를 "N일차"로 사용합니다.
  List<int> get _distinctDayNumbers {
    final set = widget.courses.map((c) => c.dayNumber).toSet().toList()
      ..sort();
    return set;
  }

  int get _dayCount => _distinctDayNumbers.isNotEmpty
      ? _distinctDayNumbers.length
      : widget.info.totalDays;

  /// 선택된 일차(dayNumber)에 해당하는 코스 후보들입니다. 하루에 코스가
  /// 여럿이면 여기 여러 개가 담깁니다.
  List<TravelCourseModel> get _coursesForSelectedDay {
    final dayNumbers = _distinctDayNumbers;
    final dayIndex = _selectedDay - 1;
    if (dayIndex < 0 || dayIndex >= dayNumbers.length) return const [];
    final targetDayNumber = dayNumbers[dayIndex];
    return widget.courses
        .where((course) => course.dayNumber == targetDayNumber)
        .toList();
  }

  TravelCourseModel? get _selectedCourse {
    final courses = _coursesForSelectedDay;
    if (courses.isEmpty) return null;
    return courses[_selectedCourseIndex.clamp(0, courses.length - 1)];
  }

  /// 선택된 일차에 속한 "모든" 코스의 여행지를 touristSpotId 기준으로 하나로
  /// 합칩니다. 같은 일차 안에서 코스를 스와이프해도 지도의 원+연결선은
  /// 이 고정된 집합 그대로이고, 오직 어떤 원이 강조(isSelected)되는지만
  /// 바뀝니다.
  ///
  /// 합친 순서는 "코스 목록에서 가장 먼저 나오는 코스"의 orderIndex 순서를
  /// 기준으로 하고, 거기 없는 장소(다른 코스에만 있는 장소)는 뒤에
  /// 덧붙입니다. 여러 코스에 같은 장소가 orderIndex/상태만 다르게 들어있는
  /// 경우, 가장 먼저 등장한 값을 그대로 씁니다.
  List<MapMarker> _mergedMarkersForSelectedDay() {
    final coursesForDay = _coursesForSelectedDay;
    if (coursesForDay.isEmpty) return const [];

    final seenSpotIds = <int>{};
    final merged = <CourseSpotModel>[];
    for (final course in coursesForDay) {
      final sorted = [...course.spots]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final spot in sorted) {
        if (seenSpotIds.add(spot.touristSpotId)) {
          merged.add(spot);
        }
      }
    }

    // 현재 보고 있는 코스(=지도 카드 제목)의 첫 번째 여행지만 강조합니다.
    int? selectedSpotId;
    final selected = _selectedCourse;
    if (selected != null && selected.spots.isNotEmpty) {
      final sortedSelected = [...selected.spots]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      selectedSpotId = sortedSelected.first.touristSpotId;
    }

    return [
      for (final spot in merged)
        MapMarker(
          position: LatLng(spot.latitude, spot.longitude),
          label: spot.name,
          status: switch (spot.status) {
            'visited' => MapMarkerStatus.visited,
            'visiting' => MapMarkerStatus.visiting,
            _ => MapMarkerStatus.notVisited,
          },
          isSelected: spot.touristSpotId == selectedSpotId,
        ),
    ];
  }

  void _handleDayChanged(int day) {
    final clamped = day.clamp(1, _dayCount);
    if (clamped == _selectedDay) return;
    setState(() {
      _selectedDay = clamped;
      // 일차가 바뀌면 그 날의 첫 번째 코스부터 다시 보여줍니다. 스와이프로
      // 이동한 코스 위치는 일차 전환 기준이 아니므로 여기서만 초기화합니다.
      _selectedCourseIndex = 0;
    });
    widget.onDayChanged?.call(clamped);
  }

  /// 지도를 좌우로 스와이프하면 "같은 일차 안에서" 다음/이전 코스로만
  /// 넘어갑니다. 일차 자체는 이 제스처로 바뀌지 않습니다.
  void _handleMapSwipe(DragEndDetails details) {
    final courses = _coursesForSelectedDay;
    if (courses.length <= 1) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -_kSwipeVelocityThreshold) {
      setState(() {
        _selectedCourseIndex = (_selectedCourseIndex + 1).clamp(
          0,
          courses.length - 1,
        );
      });
    } else if (velocity >= _kSwipeVelocityThreshold) {
      setState(() {
        _selectedCourseIndex = (_selectedCourseIndex - 1).clamp(
          0,
          courses.length - 1,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesForSelectedDay = _coursesForSelectedDay;
    final coursePageCount = coursesForSelectedDay.isEmpty
        ? 1
        : coursesForSelectedDay.length;
    final coursePageIndex = coursesForSelectedDay.isEmpty
        ? 0
        : _selectedCourseIndex.clamp(0, coursePageCount - 1);

    return Scaffold(
      backgroundColor: AppColors.white,
      // 배경 사진이 있는 상단 영역도 스크롤에 포함되어야 하므로, 화면 전체를
      // 하나의 CustomScrollView로 구성합니다. 아래쪽 시스템 인셋(제스처 바 등)만
      // 반영하면 되므로 top은 SafeArea에서 제외하고, 상단 여백은 사진 영역
      // 안쪽의 SafeArea(bottom: false)에서 상태 바 기준으로 직접 처리합니다.
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                height: _kPhotoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: widget.backgroundImage, fit: BoxFit.cover),
                    SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TravelDetailTopBar는 자체적으로 좌우 16만큼의 아이콘
                          // 여백을 두므로, 바깥에서 다시 24 패딩을 주면 이중으로
                          // 밀려나 보입니다. 화면 폭 그대로 전달합니다.
                          TravelDetailTopBar(
                            title: widget.info.destination,
                            showSettingsButton: true,
                            travelStatus: widget.status,
                            iconColor: AppColors.white,
                            textColor: AppColors.white,
                            onBackTap: widget.onBackTap,
                            onSettingsTap: widget.onSettingsTap,
                            onMemberTap: widget.onMemberTap,
                            onLeaveTap: widget.onLeaveTap,
                            onDeleteTap: widget.onDeleteTap,
                          ),
                          const SizedBox(height: _kTopBarToInfoCardGap),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _kHorizontalPadding,
                            ),
                            child: TravelInfoCard(info: widget.info),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _kPhotoToDateSelectGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kHorizontalPadding,
                    ),
                    child: AppDateDetailSelect(
                      dayCount: _dayCount,
                      selectedDay: _selectedDay,
                      onChanged: _handleDayChanged,
                    ),
                  ),
                  const SizedBox(height: _kDateSelectToMapCardGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kHorizontalPadding,
                    ),
                    // 선택된 일차 안에 코스 후보가 여럿일 수 있으므로,
                    // 좌우로 스와이프해 같은 일차 안의 다음/이전 코스로
                    // 넘어갈 수 있게 합니다(일차 자체는 위 날짜 탭으로만
                    // 바뀝니다). 페이지 인디케이터(하단 점)는 선택된
                    // 일차의 코스 개수를 보여줍니다.
                    child: GestureDetector(
                      onHorizontalDragEnd: _handleMapSwipe,
                      child: AppMapCard(
                        title: _selectedCourse?.firstSpotName ?? '',
                        markers: _mergedMarkersForSelectedDay(),
                        currentPage: coursePageIndex,
                        pageCount: coursePageCount,
                        onCourseTap: widget.onCourseTap,
                      ),
                    ),
                  ),
                  const SizedBox(height: _kMapCardToStatusGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kHorizontalPadding,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TravelStatusIndicator(
                        mode: widget.status == AppTravelStatus.inProgress
                            ? TravelStatusMode.traveling
                            : TravelStatusMode.notTraveling,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: TravelDetailBottomSection(
                status: widget.status,
                companionCount: widget.info.companionCount,
                onSaveLogTap: widget.onSaveLogTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TravelInfoCardModel _previewInfo() {
  return TravelInfoCardModel(
    destination: '경주',
    startDate: DateTime(2026, 6, 5),
    endDate: DateTime(2026, 6, 7),
    companionCount: 3,
    tags: const ['기록', '미식'],
    visitedPlaceCount: 12,
    recordCount: 48,
    completionRate: 0.6,
  );
}

List<TravelCourseModel> _previewCourses() {
  return [
    // 1일차 코스 후보 A — 지도를 스와이프하면 아래 courseId 2(코스 후보 B)로
    // 넘어갑니다. 일차(dayNumber)는 둘 다 1로 동일합니다.
    TravelCourseModel(
      courseId: 1,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: const [
        CourseSpotModel(
          courseSpotId: 1,
          touristSpotId: 1,
          name: '동궁과 월지',
          latitude: 35.8347,
          longitude: 129.2247,
          orderIndex: 0,
          status: 'visited',
        ),
        CourseSpotModel(
          courseSpotId: 2,
          touristSpotId: 2,
          name: '첨성대',
          latitude: 35.8347,
          longitude: 129.2194,
          orderIndex: 1,
          status: 'notVisited',
        ),
      ],
    ),
    // 1일차 코스 후보 B.
    TravelCourseModel(
      courseId: 2,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: const [
        CourseSpotModel(
          courseSpotId: 3,
          touristSpotId: 3,
          name: '대릉원',
          latitude: 35.8351,
          longitude: 129.2118,
          orderIndex: 0,
          status: 'notVisited',
        ),
      ],
    ),
    TravelCourseModel(
      courseId: 3,
      dayNumber: 2,
      date: DateTime(2026, 6, 6),
      spots: const [
        CourseSpotModel(
          courseSpotId: 4,
          touristSpotId: 4,
          name: '불국사',
          latitude: 35.7898,
          longitude: 129.3320,
          orderIndex: 0,
          status: 'notVisited',
        ),
        CourseSpotModel(
          courseSpotId: 5,
          touristSpotId: 5,
          name: '석굴암',
          latitude: 35.7947,
          longitude: 129.3492,
          orderIndex: 1,
          status: 'notVisited',
        ),
      ],
    ),
    TravelCourseModel(
      courseId: 4,
      dayNumber: 3,
      date: DateTime(2026, 6, 7),
      spots: const [
        CourseSpotModel(
          courseSpotId: 6,
          touristSpotId: 6,
          name: '보문관광단지',
          latitude: 35.8484,
          longitude: 129.2712,
          orderIndex: 0,
          status: 'notVisited',
        ),
      ],
    ),
  ];
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 전', size: Size(390, 844))
Widget travelDetailScreenUpcomingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.upcoming,
      courses: _previewCourses(),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 중', size: Size(390, 844))
Widget travelDetailScreenInProgressPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.inProgress,
      courses: _previewCourses(),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 후', size: Size(390, 844))
Widget travelDetailScreenCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.completed,
      courses: _previewCourses(),
    ),
  );
}
