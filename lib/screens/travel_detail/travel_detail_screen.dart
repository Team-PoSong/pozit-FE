import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../core/location/course_visiting.dart';
import '../../core/network/api_exception.dart';
import '../../data/datasources/local/travel_detail_guide_storage.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/models/travel/travel_member_model.dart';
import 'widgets/travel_detail_bottom_section.dart';
import 'widgets/travel_detail_guide_overlay.dart';
import 'widgets/travel_detail_public_actions.dart';
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
    required this.title,
    required this.info,
    required this.status,
    required this.isLeader,
    this.isPublic = true,
    this.isMyTravel = true,
    this.authorName = '',
    this.isFavorite = false,
    this.courses = const [],
    this.members = const [],
    this.backgroundImage = const AssetImage(AppImages.travelMockup),
    this.initialDay = 1,
    this.initialSpotIndex = 0,
    this.onBackTap,
    this.onSettingsTap,
    this.onCourseEditTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
    this.onCourseTap,
    this.onDayChanged,
    this.onSaveLogTap,
    this.onCameraTap,
    this.onFavoriteChanged,
    this.onFavoriteToggle,
    this.onFollowCourseTap,
    this.localThumbnails = const {},
    this.pendingThumbnailSpotIds = const {},
    this.myUserId,
    this.guideStorage = const TravelDetailGuideStorage(),
  });

  final String title;
  final TravelInfoCardModel info;
  final AppTravelStatus status;

  final bool isLeader;
  final bool isPublic;
  final bool isMyTravel;
  final String authorName;
  final bool isFavorite;

  final List<TravelCourseModel> courses;

  final List<TravelMemberModel> members;
  final ImageProvider<Object> backgroundImage;
  final int initialDay;

  final int initialSpotIndex;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCourseEditTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  final ValueChanged<int>? onCourseTap;
  final ValueChanged<int>? onDayChanged;
  final VoidCallback? onSaveLogTap;

  final ValueChanged<int>? onCameraTap;
  final ValueChanged<bool>? onFavoriteChanged;
  final Future<void> Function(bool isFavorite)? onFavoriteToggle;
  final VoidCallback? onFollowCourseTap;

  final Map<int, String> localThumbnails;

  final Set<int> pendingThumbnailSpotIds;

  final int? myUserId;

  final TravelDetailGuideStorage guideStorage;

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> {
  late int _selectedDay = widget.initialDay;

  late int _selectedSpotIndex = widget.initialSpotIndex;

  final GlobalKey _courseButtonKey = GlobalKey();
  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _cameraKey = GlobalKey();

  bool _showGuide = false;
  late bool _isFavorite = widget.isFavorite;
  bool _isFavoriteUpdating = false;

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
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
    if (oldWidget.isMyTravel != widget.isMyTravel) {
      if (widget.isMyTravel && widget.status == AppTravelStatus.inProgress) {
        _startLocationTracking();
      } else {
        _positionSubscription?.cancel();
        _positionSubscription = null;
        _currentLocation = null;
      }
    }
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
      mounted &&
      widget.isMyTravel &&
      widget.status == AppTravelStatus.inProgress;

  Future<void> _startLocationTracking() async {
    if (!_shouldTrackLocation) return;
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
    if (widget.onBackTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  int get _dayCount => widget.info.totalDays;

  List<CourseSpotModel> get _mergedSpotsForSelectedDay =>
      mergeSpotsForDay(widget.courses, _selectedDay);

  CourseSpotModel? get _focusedSpot {
    final merged = _mergedSpotsForSelectedDay;
    if (merged.isEmpty) return null;
    return merged[_selectedSpotIndex.clamp(0, merged.length - 1)];
  }

  Set<int> get _nearbySpotIds =>
      nearbyTouristSpotIds(_currentLocation, _mergedSpotsForSelectedDay);

  bool get _isCameraReady {
    final focused = _focusedSpot;
    return widget.status == AppTravelStatus.inProgress &&
        focused != null &&
        _nearbySpotIds.contains(focused.touristSpotId);
  }

  CourseSpotModel? get _activeCameraSpot =>
      _isCameraReady ? _focusedSpot : null;

  bool get _isFocusedSpotThumbnailPending {
    final spot = _focusedSpot;
    if (spot == null) return false;
    return widget.pendingThumbnailSpotIds.contains(spot.courseSpotId);
  }

  String? _latestThumbnailForUser(CourseSpotModel spot, int userId) {
    String? found;
    for (final pozing in spot.pozings) {
      if (pozing.userId == userId && pozing.thumbnailUrl.isNotEmpty) {
        found = pozing.thumbnailUrl;
      }
    }
    return found;
  }

  Map<int, String> get _focusedSpotMemberThumbnails {
    final spot = _focusedSpot;
    if (spot == null) return const {};

    final thumbnails = <int, String>{};
    for (final member in widget.members) {
      final url = _latestThumbnailForUser(spot, member.userId);
      if (url != null) thumbnails[member.userId] = url;
    }

    final myUserId = widget.myUserId;
    final localUrl = widget.localThumbnails[spot.courseSpotId];
    if (myUserId != null && localUrl != null && localUrl.isNotEmpty) {
      thumbnails[myUserId] = localUrl;
    }
    return thumbnails;
  }

  List<MapMarker> _mergedMarkersForSelectedDay() {
    final merged = _mergedSpotsForSelectedDay;
    if (merged.isEmpty) return const [];

    final focusedSpotId = _focusedSpot?.touristSpotId;
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
          isSelected: spot.touristSpotId == focusedSpotId,
        ),
    ];
  }

  void _handleDayChanged(int day) {
    final clamped = day.clamp(1, _dayCount);
    if (clamped == _selectedDay) return;
    setState(() {
      _selectedDay = clamped;

      _selectedSpotIndex = 0;
    });
    widget.onDayChanged?.call(clamped);
  }

  void _handleMapSwipe(DragEndDetails details) {
    final spotCount = _mergedSpotsForSelectedDay.length;
    if (spotCount <= 1) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -_kSwipeVelocityThreshold) {
      setState(() {
        _selectedSpotIndex = (_selectedSpotIndex + 1).clamp(0, spotCount - 1);
      });
    } else if (velocity >= _kSwipeVelocityThreshold) {
      setState(() {
        _selectedSpotIndex = (_selectedSpotIndex - 1).clamp(0, spotCount - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotsForSelectedDay = _mergedSpotsForSelectedDay;
    final spotPageCount = spotsForSelectedDay.isEmpty
        ? 1
        : spotsForSelectedDay.length;
    final spotPageIndex = spotsForSelectedDay.isEmpty
        ? 0
        : _selectedSpotIndex.clamp(0, spotPageCount - 1);

    return Stack(
      children: [
        _buildScaffold(spotPageCount, spotPageIndex),
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

  Widget _buildScaffold(int spotPageCount, int spotPageIndex) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: widget.isMyTravel
          ? null
          : TravelDetailPublicActions(
              authorName: widget.authorName,
              isFavorite: _isFavorite,
              onFavoriteTap: _isFavoriteUpdating ? null : _toggleFavorite,
              onFollowCourseTap: widget.onFollowCourseTap,
            ),

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
                    const ColoredBox(color: AppColors.dim30),
                    SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TravelDetailTopBar(
                            title: widget.title,
                            showLock: !widget.isPublic,
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
                            title: _focusedSpot?.name ?? '',
                            markers: _mergedMarkersForSelectedDay(),
                            currentPage: spotPageIndex,
                            pageCount: spotPageCount,
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
                        TravelDetailBottomSection(
                          status: widget.status,
                          members: widget.members,
                          myUserId: widget.myUserId,
                          onSaveLogTap: widget.onSaveLogTap,
                          cameraKey: _cameraKey,
                          courseTransitionKey: '$_selectedDay-$spotPageIndex',
                          isCameraReady: _isCameraReady,
                          memberThumbnails: _focusedSpotMemberThumbnails,
                          isCameraThumbnailPending:
                              _isFocusedSpotThumbnailPending,
                          onCameraTap:
                              widget.isMyTravel && _activeCameraSpot != null
                              ? () => widget.onCameraTap?.call(
                                  _activeCameraSpot!.courseSpotId,
                                )
                              : null,
                          showSaveLogButton: widget.isMyTravel,
                        ),
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

  Future<void> _toggleFavorite() async {
    final next = !_isFavorite;
    setState(() => _isFavoriteUpdating = true);
    try {
      await widget.onFavoriteToggle?.call(next);
      if (!mounted) return;
      setState(() => _isFavorite = next);
      widget.onFavoriteChanged?.call(next);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : '찜 상태를 변경하지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isFavoriteUpdating = false);
    }
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

const List<TravelMemberModel> _previewMembers = [
  TravelMemberModel(userId: 1, nickname: '민서', isLeader: true),
  TravelMemberModel(userId: 2, nickname: '윤지', isLeader: false),
  TravelMemberModel(userId: 3, nickname: '해림', isLeader: false),
];

@Preview(
  group: 'travel_detail',
  name: 'TravelDetailScreen - 여행 전',
  size: Size(390, 844),
)
Widget travelDetailScreenUpcomingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      title: '경주 여행!!',
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
      title: '경주 여행!!',
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
      title: '경주 여행!!',
      info: _previewInfo(),
      status: AppTravelStatus.completed,
      isLeader: true,
      courses: _previewCourses(),
    ),
  );
}

@Preview(group: 'haerim', name: '공개 여행 상세', size: Size(390, 844))
Widget publicTravelDetailScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      title: '경주 여행',
      info: _previewInfo(),
      status: AppTravelStatus.completed,
      isLeader: false,
      isMyTravel: false,
      authorName: '윤지',
      isFavorite: true,
      courses: _previewCourses(),
      members: _previewMembers,
      onFollowCourseTap: _ignoreTap,
    ),
  );
}

void _ignoreTap() {}
