import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_bottom_gradient.dart';
import '../../core/design_system/widgets/app_main_header.dart';
import '../../core/design_system/widgets/app_make_travel.dart';
import '../../core/design_system/widgets/app_navigationbar.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../core/location/course_visiting.dart';
import '../../data/models/saved_travel_model.dart';
import '../../data/models/travel/active_course_spot_model.dart';
import '../../data/repositories/local/travel_store.dart';
import '../../data/repositories/pozing/pozing_repository.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../explore/explore_content.dart';
import '../invite_code/invite_code_screen.dart';
import '../likes/likes_screen.dart';
import '../notification/notification_screen.dart';
import '../pozing_camera/pozing_camera_screen.dart';
import '../travel_creation/travel_creation_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import '../travel_detail/travel_detail_screen.dart';
import 'widgets/travel_completion_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.incompleteCount = 0,
    this.completeCount = 0,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onWishTap,
    this.onMyPageTap,
    this.onCreateTravelTap,
    this.onJoinWithInviteCodeTap,
    this.onNavigationChanged,
    this.onPosongTap,
    this.exploreContent = const ExploreContent(),
    this.initialTab = AppNavigationTab.travel,
    this.isCameraReady = false,
    this.assetPackage,
    this.travelRepository = const TravelRepository(),
    this.pozingRepository = const PozingRepository(),
  });

  final int incompleteCount;
  final int completeCount;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWishTap;
  final VoidCallback? onMyPageTap;
  final VoidCallback? onCreateTravelTap;
  final VoidCallback? onJoinWithInviteCodeTap;
  final ValueChanged<AppNavigationTab>? onNavigationChanged;
  final VoidCallback? onPosongTap;
  final Widget exploreContent;
  final AppNavigationTab initialTab;
  final bool isCameraReady;
  final String? assetPackage;
  final TravelRepository travelRepository;
  final PozingRepository pozingRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _travelListTopGap = 20;
  static const int _activeSpotsMaxRetryCount = 2;
  static const Duration _activeSpotsRetryDelay = Duration(milliseconds: 500);

  final _travelMenuController = OverlayPortalController();
  final _travelMenuButtonKey = GlobalKey();

  TravelCompletionStatus _selectedStatus = TravelCompletionStatus.incomplete;
  late final PageController _pageController;
  late AppNavigationTab _selectedTab;
  bool _isTravelMenuOpen = false;

  List<ActiveCourseSpotModel> _activeSpots = const [];
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _pageController = PageController(initialPage: _selectedTab.index);
    _loadActiveSpots();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _moveToTab(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveSpots() async {
    for (var attempt = 0; attempt <= _activeSpotsMaxRetryCount; attempt++) {
      try {
        final spots = await widget.travelRepository.getActiveCourseSpots();
        if (!mounted) return;
        setState(() => _activeSpots = spots);
        if (spots.isNotEmpty) unawaited(_startLocationTracking());
        return;
      } catch (error, stackTrace) {
        if (attempt >= _activeSpotsMaxRetryCount) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'HomeScreen',
              context: ErrorDescription('진행 중인 코스 정보를 불러오는 중'),
            ),
          );
          return;
        }
        await Future<void>.delayed(
          _activeSpotsRetryDelay * (attempt + 1),
        );
        if (!mounted) return;
      }
    }
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

  Future<void> _startLocationTracking() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission || !mounted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(
          () =>
              _currentLocation = LatLng(position.latitude, position.longitude),
        );
      }
    } catch (_) {}

    if (!mounted) return;

    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (position) {
            if (!mounted) return;
            setState(
              () => _currentLocation = LatLng(
                position.latitude,
                position.longitude,
              ),
            );
          },
          onError: (_) {
            if (!mounted) return;
            setState(() => _currentLocation = null);
          },
        );
  }

  ActiveCourseSpotModel? get _nearbyActiveSpot =>
      nearbyActiveCourseSpot(_currentLocation, _activeSpots);

  bool get _isVisitingCameraReady => _nearbyActiveSpot != null;

  VoidCallback? get _effectivePosongTap {
    if (widget.onPosongTap != null) return widget.onPosongTap;
    final spot = _nearbyActiveSpot;
    if (spot == null) return null;
    return () => _openPozingCameraScreen(spot);
  }

  Future<void> _openPozingCameraScreen(ActiveCourseSpotModel spot) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PozingCameraScreen(
          courseSpotId: spot.courseSpotId,
          repository: widget.pozingRepository,
        ),
      ),
    );
  }

  void _toggleTravelMenu() {
    setState(() => _isTravelMenuOpen = !_isTravelMenuOpen);

    if (_isTravelMenuOpen) {
      _travelMenuController.show();
    } else {
      _travelMenuController.hide();
    }
  }

  void _handleCreateTravel() {
    _toggleTravelMenu();
    final onCreateTravelTap = widget.onCreateTravelTap;
    if (onCreateTravelTap != null) {
      onCreateTravelTap();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TravelCreationScreen()),
    );
  }

  void _handleJoinWithInviteCode() {
    _toggleTravelMenu();
    if (widget.onJoinWithInviteCodeTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const InviteCodeScreen()));
  }

  void _openSavedTravel(SavedTravelModel travel) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelDetailScreen(
          title: travel.title,
          info: travel.info,
          status: travel.status,
          isLeader: true,
          isPublic: false,
          backgroundImage:
              travel.backgroundImage ??
              const AssetImage(AppImages.travelMockup),
          courses: travel.courses,
          onCourseTap: (day) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TravelCourseMapScreen(
                  courses: travel.courses,
                  status: travel.status,
                  totalDays: travel.info.totalDays,
                  initialDay: day,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNavigationChanged(AppNavigationTab tab) {
    _moveToTab(tab);
    widget.onNavigationChanged?.call(tab);
  }

  void _handleWishTap() {
    if (widget.onWishTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const LikesScreen()));
  }

  void _handleNotificationTap() {
    if (widget.onNotificationTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const NotificationScreen()));
  }

  void _moveToTab(AppNavigationTab tab) {
    if (_selectedTab == tab) return;

    if (_isTravelMenuOpen) {
      _isTravelMenuOpen = false;
      _travelMenuController.hide();
    }

    setState(() => _selectedTab = tab);

    if (!_pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(tab.index);
        }
      });
      return;
    }

    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: AppBottomGradient()),
          AppNavigationBar(
            selectedTab: _selectedTab,
            onChanged: _handleNavigationChanged,
            onPosongTap: _effectivePosongTap,
            isCameraReady: widget.isCameraReady || _isVisitingCameraReady,
            assetPackage: widget.assetPackage,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppMainHeader(
              hasNotification: widget.hasNotification,
              onNotificationTap: _handleNotificationTap,
              onWishTap: _handleWishTap,
              onMyPageTap: widget.onMyPageTap,
              assetPackage: widget.assetPackage,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child:
                                  ValueListenableBuilder<
                                    List<SavedTravelModel>
                                  >(
                                    valueListenable:
                                        TravelStore.instance.travels,
                                    builder: (context, travels, _) {
                                      return TravelCompletionToggle(
                                        incompleteCount: travels
                                            .where(
                                              (travel) =>
                                                  travel.status !=
                                                  AppTravelStatus.completed,
                                            )
                                            .length,
                                        completeCount: travels
                                            .where(
                                              (travel) =>
                                                  travel.status ==
                                                  AppTravelStatus.completed,
                                            )
                                            .length,
                                        selectedStatus: _selectedStatus,
                                        onChanged: (status) {
                                          setState(
                                            () => _selectedStatus = status,
                                          );
                                        },
                                      );
                                    },
                                  ),
                            ),
                            const SizedBox(width: 11),
                            OverlayPortal(
                              controller: _travelMenuController,
                              overlayChildBuilder: (context) {
                                final buttonContext =
                                    _travelMenuButtonKey.currentContext;
                                final buttonRenderObject = buttonContext
                                    ?.findRenderObject();

                                if (buttonRenderObject is! RenderBox ||
                                    !buttonRenderObject.hasSize) {
                                  return const SizedBox.shrink();
                                }

                                final overlayRenderObject = Overlay.of(
                                  context,
                                ).context.findRenderObject();
                                if (overlayRenderObject is! RenderBox ||
                                    !overlayRenderObject.hasSize) {
                                  return const SizedBox.shrink();
                                }

                                final buttonBox = buttonRenderObject;
                                final buttonOffset = buttonBox.localToGlobal(
                                  Offset.zero,
                                  ancestor: overlayRenderObject,
                                );
                                final overlayWidth =
                                    overlayRenderObject.size.width;

                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ExcludeSemantics(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: _toggleTravelMenu,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top:
                                          buttonOffset.dy +
                                          buttonBox.size.height +
                                          10,
                                      right:
                                          overlayWidth -
                                          buttonOffset.dx -
                                          buttonBox.size.width,
                                      child: _TravelMenuPopover(
                                        onCreateTravelTap: _handleCreateTravel,
                                        onJoinWithInviteCodeTap:
                                            _handleJoinWithInviteCode,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              child: Semantics(
                                key: _travelMenuButtonKey,
                                button: true,
                                expanded: _isTravelMenuOpen,
                                label: _isTravelMenuOpen
                                    ? '여행 메뉴 닫기'
                                    : '여행 메뉴 열기',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _toggleTravelMenu,
                                  child: DecoratedBox(
                                    decoration: const ShapeDecoration(
                                      color: AppColors.purple3,
                                      shape: CircleBorder(),
                                    ),
                                    child: SizedBox.square(
                                      dimension: 43,
                                      child: Center(
                                        child: AnimatedRotation(
                                          turns: _isTravelMenuOpen ? 0.125 : 0,
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          curve: Curves.easeOut,
                                          child: SvgPicture.asset(
                                            AppIcons.travelPlus,
                                            package: widget.assetPackage,
                                            width: 24,
                                            height: 24,
                                            excludeFromSemantics: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: _travelListTopGap),
                      Expanded(
                        child: ValueListenableBuilder<List<SavedTravelModel>>(
                          valueListenable: TravelStore.instance.travels,
                          builder: (context, travels, _) {
                            final filteredTravels = travels.where((travel) {
                              final isCompleted =
                                  travel.status == AppTravelStatus.completed;
                              return _selectedStatus ==
                                      TravelCompletionStatus.complete
                                  ? isCompleted
                                  : !isCompleted;
                            }).toList();
                            if (filteredTravels.isEmpty) {
                              return Column(
                                children: [
                                  const Spacer(flex: 7),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        AppImages.posongCarrier,
                                        package: widget.assetPackage,
                                        width: 219,
                                        height: 150,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        '여행이 없어요! 포짓과 함께 떠나볼까요?',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.gray5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(flex: 9),
                                ],
                              );
                            }
                            return ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                8,
                                24,
                                AppNavigationBar.clearance(context),
                              ),
                              itemCount: filteredTravels.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final travel = filteredTravels[index];
                                return AppTravelCard(
                                  type: AppTravelCardType.myTravel,
                                  title: travel.title,
                                  location: travel.location,
                                  dateText: travel.dateText,
                                  author: travel.author,
                                  status: travel.status,
                                  dDay: travel.dDay,
                                  tags: travel.tags,
                                  participantCount: travel.participantCount,
                                  backgroundImage: travel.backgroundImage,
                                  isPublic: false,
                                  onTap: () => _openSavedTravel(travel),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  widget.exploreContent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelMenuPopover extends StatelessWidget {
  const _TravelMenuPopover({
    required this.onCreateTravelTap,
    required this.onJoinWithInviteCodeTap,
  });

  final VoidCallback onCreateTravelTap;
  final VoidCallback onJoinWithInviteCodeTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('travel-menu-popover'),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray3, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppMakeTravel(
              type: AppMakeTravelType.create,
              isSelected: true,
              onPressed: onCreateTravelTap,
            ),
            const SizedBox(height: 6),
            AppMakeTravel(
              type: AppMakeTravelType.joinWithInviteCode,
              isSelected: false,
              onPressed: onJoinWithInviteCodeTap,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Home Screen', size: Size(393, 852))
Widget homeScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: HomeScreen(assetPackage: 'pozit'),
    ),
  );
}
