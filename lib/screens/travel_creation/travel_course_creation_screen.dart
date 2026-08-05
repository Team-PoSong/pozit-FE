import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_location.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/button/app_chatbot_button.dart';
import '../../core/design_system/widgets/button/app_circle_button.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../../data/models/tourist_spot_model.dart';
import '../location_search/location_search_screen.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_creation_data.dart';

const List<TouristSpotModel> _mockPopularSpots = [
  TouristSpotModel(
    touristSpotId: 1,
    name: '불국사',
    address: '경북 경주시 불국로 385',
    latitude: 35.7900,
    longitude: 129.3320,
  ),
  TouristSpotModel(
    touristSpotId: 2,
    name: '미륵사지',
    address: '경북 경주시 원화로 102',
    latitude: 35.8347,
    longitude: 129.2247,
  ),
  TouristSpotModel(
    touristSpotId: 3,
    name: '경주월드',
    address: '경북 보문로 544',
    latitude: 35.8364,
    longitude: 129.2827,
  ),
];

class TravelCourseCreationScreen extends StatefulWidget {
  const TravelCourseCreationScreen({
    super.key,
    required this.travelInfo,
    this.courseCounts = const {},
    this.onAiTap,
    this.onAddCourseTap,
    this.onStartTravel,
    this.onBackTap,
  });

  final TravelInfoResult travelInfo;
  final Map<int, int> courseCounts;
  final VoidCallback? onAiTap;
  final ValueChanged<int>? onAddCourseTap;
  final VoidCallback? onStartTravel;
  final VoidCallback? onBackTap;

  @override
  State<TravelCourseCreationScreen> createState() =>
      _TravelCourseCreationScreenState();
}

class _TravelCourseCreationScreenState
    extends State<TravelCourseCreationScreen> {
  int _selectedDay = 1;
  late final Map<int, int> _courseCounts;
  final Map<int, List<TouristSpotModel>> _spotsByDay = {};

  @override
  void initState() {
    super.initState();
    _courseCounts = {...widget.courseCounts};
  }

  int get _dayCount =>
      widget.travelInfo.dateRange.duration.inDays.clamp(0, 3) + 1;

  bool get _hasAnyCourse =>
      _courseCounts.values.any((count) => count > 0) ||
      _spotsByDay.values.any((spots) => spots.isNotEmpty);

  Future<List<TouristSpotModel>> _searchMockSpots(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    return _mockPopularSpots
        .where(
          (spot) =>
              spot.name.toLowerCase().contains(normalizedQuery) ||
              spot.address.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  Future<void> _handleAddCourseTap() async {
    final callback = widget.onAddCourseTap;
    if (callback != null) {
      callback(_selectedDay);
      return;
    }

    final spots = await Navigator.of(context).push<List<TouristSpotModel>>(
      MaterialPageRoute<List<TouristSpotModel>>(
        builder: (_) => LocationSearchScreen(
          popularSpots: _mockPopularSpots,
          onSearch: _searchMockSpots,
        ),
      ),
    );
    if (!mounted || spots == null || spots.isEmpty) return;

    setState(() {
      final selectedSpots = _spotsByDay.putIfAbsent(
        _selectedDay,
        () => <TouristSpotModel>[],
      );
      final existingIds = selectedSpots
          .map((spot) => spot.touristSpotId)
          .toSet();
      for (final spot in spots) {
        if (existingIds.add(spot.touristSpotId)) selectedSpots.add(spot);
      }
      _courseCounts[_selectedDay] = selectedSpots.length;
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final spots = _spotsByDay[_selectedDay]!;
      final spot = spots.removeAt(oldIndex);
      spots.insert(newIndex, spot);
    });
  }

  void _handleDelete(TouristSpotModel spot) {
    setState(() {
      final spots = _spotsByDay[_selectedDay]!;
      spots.removeWhere((item) => item.touristSpotId == spot.touristSpotId);
      _courseCounts[_selectedDay] = spots.length;
    });
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDaySpots = _spotsByDay[_selectedDay] ?? const [];
    final selectedDayCourseCount = _courseCounts[_selectedDay] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
                Positioned(
                  right: 24,
                  top: 14.5,
                  child: AppChatbotButton(onPressed: widget.onAiTap),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 2),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppDateDetailSelect(
                dayCount: _dayCount,
                selectedDay: _selectedDay,
                onChanged: (day) => setState(() => _selectedDay = day),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$_selectedDay일차${selectedDayCourseCount > 0 ? ' 코스' : ''}',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: selectedDayCourseCount == 0
                  ? const _EmptyCourseState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      buildDefaultDragHandles: false,
                      itemCount: selectedDaySpots.length,
                      onReorderItem: _handleReorder,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) => Material(
                            elevation: animation.value * 1.5,
                            color: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                            child: child,
                          ),
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final spot = selectedDaySpots[index];
                        return Padding(
                          key: ValueKey(spot.touristSpotId),
                          padding: const EdgeInsets.only(bottom: 8),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: AppCircleButton(
                  size: 62,
                  backgroundColor: AppColors.purple3,
                  iconAsset: AppIcons.plus,
                  onPressed: _handleAddCourseTap,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '여행 시작하기',
                isEnabled: _hasAnyCourse,
                onPressed: widget.onStartTravel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourseState extends StatelessWidget {
  const _EmptyCourseState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.pin,
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          Text(
            '코스를 만들어볼까요?',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.gray5),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Course Creation', size: Size(393, 852))
Widget travelCourseCreationScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelCourseCreationScreen(
        travelInfo: TravelInfoResult(
          destination: '경상북도 경주시',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 6),
          ),
          name: '포송한 여행',
          tags: const {'미식', '문화'},
        ),
      ),
    ),
  );
}
