import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/location/course_visiting.dart';
import '../../data/datasources/local/travel_detail_guide_storage.dart';
import '../../data/models/travel_course_model.dart';
import '../../data/models/travel_info_card_model.dart';
import 'widgets/travel_detail_bottom_section.dart';
import 'widgets/travel_detail_guide_overlay.dart';
import 'widgets/travel_detail_top_bar.dart';
import 'widgets/travel_info_card.dart';
import 'widgets/travel_status.dart';

const double _kPhotoHeight = 290.0;
const double _kHorizontalPadding = 24.0;

const double _kTopBarToInfoCardGap = 30.0;
const double _kPhotoToDateSelectGap = 17.0;
const double _kDateSelectToMapCardGap = 10.0;
const double _kMapCardToStatusGap = 8.0;

const double _kSwipeVelocityThreshold = 200.0;

class TravelDetailScreen extends StatefulWidget {
  const TravelDetailScreen({
    super.key,
    required this.info,
    required this.status,
    required this.isLeader,
    this.isMyTravel = true,
    this.authorName = '',
    this.publicDescription,
    this.isFavorite = false,
    this.courses = const [],
    this.backgroundImage = const AssetImage(AppImages.travelMockup),
    this.initialDay = 1,
    this.onBackTap,
    this.onSettingsTap,
    this.onCourseEditTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
    this.onCourseTap,
    this.onDayChanged,
    this.onSaveLogTap,
    this.onFavoriteTap,
    this.onFollowCourseTap,
    this.guideStorage = const TravelDetailGuideStorage(),
  });

  final TravelInfoCardModel info;
  final AppTravelStatus status;

  final bool isLeader;
  final bool isMyTravel;
  final String authorName;
  final String? publicDescription;
  final bool isFavorite;

  final List<TravelCourseModel> courses;
  final ImageProvider<Object> backgroundImage;
  final int initialDay;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCourseEditTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  final ValueChanged<int>? onCourseTap;
  final ValueChanged<int>? onDayChanged;
  final VoidCallback? onSaveLogTap;
  final ValueChanged<bool>? onFavoriteTap;
  final VoidCallback? onFollowCourseTap;

  final TravelDetailGuideStorage guideStorage;

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> {
  late int _selectedDay = widget.initialDay;

  int _selectedCourseIndex = 0;

  final GlobalKey _courseButtonKey = GlobalKey();
  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _cameraKey = GlobalKey();

  bool _showGuide = false;
  late bool _isFavorite = widget.isFavorite;
  bool _isFollowingCourse = false;

  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _maybeShowGuide();
    if (widget.status == AppTravelStatus.inProgress) {
      _startLocationTracking();
    }
  }

  @override
  void didUpdateWidget(covariant TravelDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status == widget.status) return;

    if (widget.status == AppTravelStatus.inProgress) {
      _startLocationTracking();
    } else if (oldWidget.status == AppTravelStatus.inProgress) {
      _positionSubscription?.cancel();
      _positionSubscription = null;
      setState(() => _currentLocation = null);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _maybeShowGuide() async {
    if (!widget.isMyTravel) return;
    if (widget.status == AppTravelStatus.completed) return;
    final dismissed = await widget.guideStorage.isDismissed(widget.status);
    if (!mounted || dismissed) return;
    setState(() => _showGuide = true);
  }

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  bool get _shouldTrackLocation =>
      mounted && widget.status == AppTravelStatus.inProgress;

  Future<void> _startLocationTracking() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission || !_shouldTrackLocation) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (_shouldTrackLocation) {
        setState(
          () =>
              _currentLocation = LatLng(position.latitude, position.longitude),
        );
      }
    } catch (_) {}

    if (!_shouldTrackLocation) return;

    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((position) {
          if (!mounted) return;
          setState(
            () => _currentLocation = LatLng(
              position.latitude,
              position.longitude,
            ),
          );
        });
  }

  void _hideGuide() {
    setState(() => _showGuide = false);
  }

  void _dismissGuideForever() {
    _hideGuide();
    widget.guideStorage.markDismissed(widget.status);
  }

  void _handleBack() {
    final onBackTap = widget.onBackTap;
    if (onBackTap != null) {
      onBackTap();
      return;
    }
    Navigator.of(context).maybePop();
  }

  int get _dayCount => widget.info.totalDays;

  List<TravelCourseModel> get _coursesForSelectedDay => widget.courses
      .where((course) => course.dayNumber == _selectedDay)
      .toList();

  TravelCourseModel? get _selectedCourse {
    final courses = _coursesForSelectedDay;
    if (courses.isEmpty) return null;
    return courses[_selectedCourseIndex.clamp(0, courses.length - 1)];
  }

  List<CourseSpotModel> get _mergedSpotsForSelectedDay {
    final seenSpotIds = <int>{};
    final merged = <CourseSpotModel>[];
    for (final course in _coursesForSelectedDay) {
      final sorted = [...course.spots]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final spot in sorted) {
        if (seenSpotIds.add(spot.touristSpotId)) {
          merged.add(spot);
        }
      }
    }
    return merged;
  }

  Set<int> get _nearbySpotIds =>
      nearbyTouristSpotIds(_currentLocation, _mergedSpotsForSelectedDay);

  bool get _isCameraReady =>
      widget.status == AppTravelStatus.inProgress && _nearbySpotIds.isNotEmpty;

  List<MapMarker> _mergedMarkersForSelectedDay() {
    final merged = _mergedSpotsForSelectedDay;
    if (merged.isEmpty) return const [];

    int? selectedSpotId;
    final selected = _selectedCourse;
    if (selected != null && selected.spots.isNotEmpty) {
      final sortedSelected = [...selected.spots]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      selectedSpotId = sortedSelected.first.touristSpotId;
    }

    final allowVisiting = widget.status == AppTravelStatus.inProgress;
    final nearbySpotIds = _nearbySpotIds;

    return [
      for (final spot in merged)
        MapMarker(
          position: LatLng(spot.latitude, spot.longitude),
          label: spot.name,
          status: switch (spot.status) {
            'visited' => MapMarkerStatus.visited,
            _
                when allowVisiting &&
                    nearbySpotIds.contains(spot.touristSpotId) =>
              MapMarkerStatus.visiting,
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

      _selectedCourseIndex = 0;
    });
    widget.onDayChanged?.call(clamped);
  }

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

    return Stack(
      children: [
        _buildScaffold(coursePageCount, coursePageIndex),
        if (_showGuide)
          TravelDetailGuideOverlay(
            courseButtonKey: _courseButtonKey,
            mapKey: _mapKey,
            cameraKey: widget.status == AppTravelStatus.inProgress
                ? _cameraKey
                : null,
            onDismiss: _hideGuide,
            onDismissForever: _dismissGuideForever,
          ),
      ],
    );
  }

  Widget _buildScaffold(int coursePageCount, int coursePageIndex) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
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
                          TravelDetailTopBar(
                            title: widget.info.destination,
                            showSettingsButton: widget.isMyTravel,
                            travelStatus: widget.status,
                            isLeader: widget.isLeader,
                            iconColor: AppColors.white,
                            textColor: AppColors.white,
                            onBackTap: _handleBack,
                            onSettingsTap: widget.onSettingsTap,
                            onCourseEditTap: widget.onCourseEditTap,
                            onMemberTap: widget.onMemberTap,
                            onLeaveTap: widget.onLeaveTap,
                            onDeleteTap: widget.onDeleteTap,
                          ),
                          const SizedBox(height: _kTopBarToInfoCardGap),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _kHorizontalPadding,
                            ),
                            child: TravelInfoCard(
                              info: widget.info,
                              showProgress: widget.isMyTravel,
                              showCompanion: widget.isMyTravel,
                              description: widget.isMyTravel
                                  ? null
                                  : (widget.publicDescription ??
                                        '${widget.authorName}님의 여행 코스'),
                            ),
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
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: _handleMapSwipe,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _kHorizontalPadding,
                          ),
                          child: AppMapCard(
                            title: _selectedCourse?.firstSpotName ?? '',
                            markers: _mergedMarkersForSelectedDay(),
                            currentPage: coursePageIndex,
                            pageCount: coursePageCount,
                            onCourseTap: () =>
                                widget.onCourseTap?.call(_selectedDay),
                            courseButtonKey: _courseButtonKey,
                            mapKey: _mapKey,
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
                        if (widget.isMyTravel)
                          TravelDetailBottomSection(
                            status: widget.status,
                            companionCount: widget.info.companionCount,
                            onSaveLogTap: widget.onSaveLogTap,
                            cameraKey: _cameraKey,
                            courseTransitionKey:
                                '$_selectedDay-$coursePageIndex',
                            isCameraReady: _isCameraReady,
                          )
                        else
                          _buildOtherTravelBottom(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherTravelBottom() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kHorizontalPadding,
        15,
        _kHorizontalPadding,
        AppDimensions.screenBottomPadding +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.authorName.isEmpty ? '여행자' : widget.authorName}님의 여행 코스를\n내 여행으로 가져와볼까요?',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 14),
          AppFavoriteButton(
            isFavorite: _isFavorite,
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onFavoriteTap?.call(_isFavorite);
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            text: _isFollowingCourse ? '여행 코스 수정하기' : '이 코스 따라하기',
            onPressed: () {
              if (!_isFollowingCourse) {
                setState(() => _isFollowingCourse = true);
                return;
              }
              widget.onFollowCourseTap?.call();
            },
          ),
        ],
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
      ],
    ),

    TravelCourseModel(
      courseId: 2,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: const [
        CourseSpotModel(
          courseSpotId: 3,
          touristSpotId: 3,
          name: '대릉원',
          address: '경북 경주시 계림로 9',
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
    TravelCourseModel(
      courseId: 4,
      dayNumber: 3,
      date: DateTime(2026, 6, 7),
      spots: const [
        CourseSpotModel(
          courseSpotId: 6,
          touristSpotId: 6,
          name: '보문관광단지',
          address: '경북 경주시 보문로 132',
          latitude: 35.8484,
          longitude: 129.2712,
          orderIndex: 0,
          status: 'notVisited',
        ),
      ],
    ),
  ];
}

@Preview(
  group: 'travel_detail',
  name: 'TravelDetailScreen - 여행 전',
  size: Size(390, 844),
)
Widget travelDetailScreenUpcomingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.upcoming,
      isLeader: true,
      courses: _previewCourses(),
    ),
  );
}

@Preview(
  group: 'travel_detail',
  name: 'TravelDetailScreen - 여행 중',
  size: Size(390, 844),
)
Widget travelDetailScreenInProgressPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.inProgress,
      isLeader: true,
      courses: _previewCourses(),
    ),
  );
}

@Preview(
  group: 'travel_detail',
  name: 'TravelDetailScreen - 여행 후',
  size: Size(390, 844),
)
Widget travelDetailScreenCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.completed,
      isLeader: true,
      courses: _previewCourses(),
    ),
  );
}
