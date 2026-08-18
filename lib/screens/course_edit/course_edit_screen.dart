import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_location.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/button/app_circle_button.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/tourist_spot_model.dart';
import '../../data/models/tourist_spot_rank_model.dart';
import '../../data/models/tourist_spot_search_result_model.dart';
import '../location_search/location_search_screen.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

const double _kHorizontalPadding = 24.0;

const double _kTopBarToDateDetailGap = 17.0;
const double _kDateDetailToTitleGap = 24.0;
const double _kTitleToListGap = 24.0;
const double _kLocationGap = 8.0;
const double _kFabToButtonGap = 22.0;
const double _kFabSize = 62.0;

class CourseEditScreen extends StatefulWidget {
  const CourseEditScreen({
    super.key,
    required this.courses,
    this.initialDay = 1,
    this.isCreationFlow = false,
    this.onLoadPopularSpots,
    this.onSearch,
    this.onAddSelectedSpots,
    this.onBackTap,
    this.onSave,
  });

  final List<TravelCourseModel> courses;
  final int initialDay;
  final bool isCreationFlow;

  final Future<TouristSpotRankPage> Function(int cursor)? onLoadPopularSpots;
  final Future<TouristSpotSearchPage> Function(String keyword, int cursor)?
  onSearch;
  final Future<List<TouristSpotModel>> Function(
    List<TouristSpotSearchResultModel> selected,
  )?
  onAddSelectedSpots;

  final VoidCallback? onBackTap;

  final ValueChanged<Map<int, List<CourseSpotModel>>>? onSave;

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  late final List<int> _dayNumbers =
      (widget.courses.map((c) => c.dayNumber).toSet().toList()..sort());

  int _dayNumberForIndex(int dayIndex) {
    while (_dayNumbers.length < dayIndex) {
      _dayNumbers.add(_dayNumbers.length + 1);
    }
    return _dayNumbers[dayIndex - 1];
  }

  late final Map<int, List<CourseSpotModel>> _spotsByDayIndex = {
    for (var i = 0; i < _dayNumbers.length; i++)
      i + 1: mergeSpotsForDay(widget.courses, _dayNumbers[i]),
  };

  late int _selectedDay = widget.initialDay;
  late bool _hasChanges = widget.onSave != null;

  int get _dayCount => _dayNumbers.isEmpty ? 1 : _dayNumbers.length;

  List<CourseSpotModel> get _spotsForSelectedDay =>
      _spotsByDayIndex[_selectedDay] ?? const [];

  void _handleDayChanged(int day) {
    setState(() => _selectedDay = day);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final list = _spotsByDayIndex[_selectedDay]!;
      final spot = list.removeAt(oldIndex);
      list.insert(newIndex, spot);
      _hasChanges = true;
    });
  }

  void _handleDelete(CourseSpotModel spot) {
    setState(() {
      _spotsByDayIndex[_selectedDay]!.remove(spot);
      _hasChanges = true;
    });
  }

  Future<void> _handleAddTap() async {
    final added = await Navigator.of(context).push<List<TouristSpotModel>>(
      MaterialPageRoute<List<TouristSpotModel>>(
        builder: (_) => LocationSearchScreen(
          onLoadPopularSpots: widget.onLoadPopularSpots,
          onSearch: widget.onSearch,
          onAddSelectedSpots: widget.onAddSelectedSpots,
        ),
      ),
    );
    if (added == null || added.isEmpty || !mounted) return;

    setState(() {
      _dayNumberForIndex(_selectedDay);
      final list = _spotsByDayIndex.putIfAbsent(_selectedDay, () => []);
      final existingSpotIds = list.map((s) => s.touristSpotId).toSet();
      for (final spot in added) {
        if (!existingSpotIds.add(spot.touristSpotId)) continue;
        list.add(
          CourseSpotModel(
            courseSpotId: spot.touristSpotId,
            touristSpotId: spot.touristSpotId,
            name: spot.name,
            address: spot.address,
            latitude: spot.latitude,
            longitude: spot.longitude,
            orderIndex: list.length,
            status: 'notVisited',
          ),
        );
      }
      _hasChanges = true;
    });
  }

  int? _courseIdForDay(int dayNumber) {
    for (final course in widget.courses) {
      if (course.dayNumber == dayNumber) return course.courseId;
    }
    return null;
  }

  void _handleSave() {
    final spotsByCourseId = <int, List<CourseSpotModel>>{};
    for (final entry in _spotsByDayIndex.entries) {
      final courseId = _courseIdForDay(_dayNumberForIndex(entry.key));
      if (courseId == null) continue;
      spotsByCourseId[courseId] = List.unmodifiable([
        for (var i = 0; i < entry.value.length; i++)
          entry.value[i].copyWith(orderIndex: i),
      ]);
    }
    widget.onSave?.call(spotsByCourseId);
    Navigator.of(context).pop();
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _spotsForSelectedDay;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TravelDetailTopBar(title: '코스 수정', onBackTap: _handleBack),
            const SizedBox(height: _kTopBarToDateDetailGap),
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
            const SizedBox(height: _kDateDetailToTitleGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: Text(
                '$_selectedDay일차 코스',
                style: AppTextStyles.headline.copyWith(color: AppColors.text),
              ),
            ),
            const SizedBox(height: _kTitleToListGap),
            Expanded(
              child: Stack(
                children: [
                  ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      _kHorizontalPadding,
                      0,
                      _kHorizontalPadding,
                      _kFabSize + _kFabToButtonGap,
                    ),
                    buildDefaultDragHandles: false,
                    itemCount: spots.length,
                    onReorderItem: _handleReorder,

                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          final elevation =
                              Curves.easeInOut.transform(animation.value) * 6;
                          return Material(
                            elevation: elevation,
                            color: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.black.withValues(alpha: 0.3),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final spot = spots[index];
                      return Padding(
                        key: ValueKey(spot.touristSpotId),
                        padding: const EdgeInsets.only(bottom: _kLocationGap),
                        child: AppLocation(
                          name: spot.name,
                          address: spot.address,
                          showReorderHandle: true,
                          reorderIndex: index,
                          onDelete: () => _handleDelete(spot),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    right: _kHorizontalPadding,
                    bottom: _kFabToButtonGap,
                    child: AppCircleButton(
                      size: _kFabSize,
                      onPressed: _handleAddTap,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _kHorizontalPadding,
                0,
                _kHorizontalPadding,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '저장하기',
                isEnabled: _hasChanges,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
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
          status: 'notVisited',
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

@Preview(group: 'course_edit', name: 'CourseEditScreen', size: Size(390, 844))
Widget courseEditScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CourseEditScreen(courses: _previewCourses()),
  );
}
