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
import '../../core/network/api_exception.dart';
import '../../data/models/tourist_spot_model.dart';
import '../../data/models/travel/travel_create_model.dart';
import '../../data/repositories/tourist_spot/tourist_spot_repository.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../location_search/location_search_screen.dart';
import '../travel_detail/travel_detail_page.dart';
import 'travel_creation_data.dart';
import 'travel_creation_pipeline.dart';
import 'widgets/travel_creation_header.dart';

class TravelCourseCreationScreen extends StatefulWidget {
  const TravelCourseCreationScreen({
    super.key,
    required this.travelInfo,
    this.onAiTap,
    this.onAddCourseTap,
    this.onStartTravel,
    this.onBackTap,
    this.travelRepository = const TravelRepository(),
    this.touristSpotRepository = const TouristSpotRepository(),
  });

  final TravelInfoResult travelInfo;
  final VoidCallback? onAiTap;
  final ValueChanged<int>? onAddCourseTap;
  final VoidCallback? onStartTravel;
  final VoidCallback? onBackTap;
  final TravelRepository travelRepository;
  final TouristSpotRepository touristSpotRepository;

  @override
  State<TravelCourseCreationScreen> createState() =>
      _TravelCourseCreationScreenState();
}

class _TravelCourseCreationScreenState
    extends State<TravelCourseCreationScreen> {
  int _selectedDay = 1;
  final Map<int, List<TouristSpotModel>> _spotsByDay = {};
  bool _isSaving = false;
  TravelCreateResult? _createdTravel;
  TravelCreateResult? _createdWishTravel;

  @override
  void initState() {
    super.initState();
    _initializeCopiedCourses();
  }

  @override
  void didUpdateWidget(covariant TravelCourseCreationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dayCountChanged =
        TravelCreationPipeline.dayCount(oldWidget.travelInfo) !=
        TravelCreationPipeline.dayCount(widget.travelInfo);
    final initialCoursesChanged = !identical(
      oldWidget.travelInfo.initialCourses,
      widget.travelInfo.initialCourses,
    );
    if (!dayCountChanged && !initialCoursesChanged) return;
    _selectedDay = _selectedDay.clamp(1, _dayCount);
    _spotsByDay.clear();
    _initializeCopiedCourses();
  }

  void _initializeCopiedCourses() {
    final initialSpots = TravelCreationPipeline.initialSpotsByDay(
      widget.travelInfo,
    );
    for (final entry in initialSpots.entries) {
      _spotsByDay[entry.key] = entry.value;
    }
  }

  int get _dayCount => TravelCreationPipeline.dayCount(widget.travelInfo);

  bool get _hasAnyCourse => _spotsByDay.values.any((spots) => spots.isNotEmpty);

  Future<void> _handleAddCourseTap() async {
    final callback = widget.onAddCourseTap;
    if (callback != null) {
      callback(_selectedDay);
      return;
    }

    final spots = await Navigator.of(context).push<List<TouristSpotModel>>(
      MaterialPageRoute<List<TouristSpotModel>>(
        builder: (_) => LocationSearchScreen(
          onLoadPopularSpots: (cursor) =>
              widget.touristSpotRepository.getHostTouristSpotsRank(
                regionCode: widget.travelInfo.regionCode,
                cursor: cursor,
              ),
          onSearch: (query, cursor) => widget.touristSpotRepository
              .searchCourseSpots(keyword: query, cursor: cursor),
          onAddSelectedSpots: widget.touristSpotRepository.saveSelectedSpots,
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
    });
  }

  void _handleBack() {
    final onBackTap = widget.onBackTap;
    if (onBackTap != null) {
      onBackTap();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleStartTravel() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final isWish =
          widget.travelInfo.creationMethod == TravelCreationMethod.wish;
      final TravelCreateResult created;
      if (isWish) {
        created =
            _createdWishTravel ??
            await widget.travelRepository.createLikeBasedTravel(
              TravelCreationPipeline.buildLikeBasedCreateRequest(
                widget.travelInfo,
                _spotsByDay,
              ),
            );
        _createdWishTravel = created;
      } else {
        created =
            _createdTravel ??
            await widget.travelRepository.createTravel(
              TravelCreationPipeline.buildCreateRequest(widget.travelInfo),
            );
        _validateCreatedCourses(created);
        _createdTravel = created;
        await Future.wait([
          for (final course in created.courses)
            if ((_spotsByDay[course.dayNumber] ?? const []).isNotEmpty)
              widget.travelRepository.updateCourseSpots(
                course.courseId,
                (_spotsByDay[course.dayNumber] ?? const [])
                    .map((spot) => spot.touristSpotId)
                    .toList(),
              ),
        ]);
      }
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => TravelDetailPage(travelId: created.travelId),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException ? error.message : '여행을 생성하지 못했어요. 다시 시도해주세요.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _validateCreatedCourses(TravelCreateResult created) {
    final expectedDays = {for (var day = 1; day <= _dayCount; day++) day};
    final actualDays = created.courses
        .map((course) => course.dayNumber)
        .toSet();
    if (created.courses.length != _dayCount ||
        actualDays.length != _dayCount ||
        !actualDays.containsAll(expectedDays)) {
      throw const ApiException('생성된 여행의 코스 정보가 올바르지 않습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDaySpots = _spotsByDay[_selectedDay] ?? const [];
    final selectedDayCourseCount = selectedDaySpots.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelCreationHeader(
              currentStepIndex: 2,
              onBackTap: _handleBack,
              trailing: AppChatbotButton(onPressed: widget.onAiTap),
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: selectedDayCourseCount == 0
                        ? const _EmptyCourseState()
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 92),
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
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.08,
                                  ),
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
                  Positioned(
                    right: 24,
                    bottom: 22,
                    child: AppCircleButton(
                      size: 62,
                      backgroundColor: AppColors.purple3,
                      iconAsset: AppIcons.plus,
                      onPressed: _handleAddCourseTap,
                    ),
                  ),
                ],
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
                text: _isSaving ? '여행을 만드는 중...' : '여행 시작하기',
                isEnabled: _hasAnyCourse && !_isSaving,
                onPressed: widget.onStartTravel ?? _handleStartTravel,
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
