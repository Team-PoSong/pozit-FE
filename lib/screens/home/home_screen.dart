import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_bottom_gradient.dart';
import '../../core/design_system/widgets/app_main_header.dart';
import '../../core/design_system/widgets/app_make_travel.dart';
import '../../core/design_system/widgets/app_navigationbar.dart';
import '../explore/explore_content.dart';
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _travelMenuController = OverlayPortalController();
  final _travelMenuButtonKey = GlobalKey();

  TravelCompletionStatus _selectedStatus = TravelCompletionStatus.incomplete;
  late final PageController _pageController;
  late AppNavigationTab _selectedTab;
  bool _isTravelMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _pageController = PageController(initialPage: _selectedTab.index);
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
    super.dispose();
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
    widget.onCreateTravelTap?.call();
  }

  void _handleJoinWithInviteCode() {
    _toggleTravelMenu();
    widget.onJoinWithInviteCodeTap?.call();
  }

  void _handleNavigationChanged(AppNavigationTab tab) {
    _moveToTab(tab);
    widget.onNavigationChanged?.call(tab);
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
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: AppBottomGradient()),
          AppNavigationBar(
            selectedTab: _selectedTab,
            onChanged: _handleNavigationChanged,
            onPosongTap: widget.onPosongTap,
            isCameraReady: widget.isCameraReady,
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
              onNotificationTap: widget.onNotificationTap,
              onWishTap: widget.onWishTap,
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
                              child: TravelCompletionToggle(
                                incompleteCount: widget.incompleteCount,
                                completeCount: widget.completeCount,
                                selectedStatus: _selectedStatus,
                                onChanged: (status) {
                                  setState(() => _selectedStatus = status);
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
                      Expanded(
                        child: Column(
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
