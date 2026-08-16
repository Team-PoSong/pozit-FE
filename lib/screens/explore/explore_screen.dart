import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_navigationbar.dart';
import '../home/home_screen.dart';
import 'explore_content.dart';

const double _detailHeaderToContentGap = 20.0;
const double _detailHeaderTopOffset = 4.0;

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
    super.key,
    this.incompleteCount = 0,
    this.completeCount = 0,
    this.isTravelCreationMode = false,
    this.onBackTap,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onWishTap,
    this.onMyPageTap,
    this.onCreateTravelTap,
    this.onJoinWithInviteCodeTap,
    this.onNavigationChanged,
    this.onPosongTap,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.onRegionFilterTap,
    this.onDateFilterTap,
    this.onCategoryFilterTap,
    this.onFilterResetTap,
    this.travels = const [],
    this.isCameraReady = false,
    this.assetPackage,
  });

  final int incompleteCount;
  final int completeCount;
  final bool isTravelCreationMode;
  final VoidCallback? onBackTap;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWishTap;
  final VoidCallback? onMyPageTap;
  final VoidCallback? onCreateTravelTap;
  final VoidCallback? onJoinWithInviteCodeTap;
  final ValueChanged<AppNavigationTab>? onNavigationChanged;
  final VoidCallback? onPosongTap;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onRegionFilterTap;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onCategoryFilterTap;
  final VoidCallback? onFilterResetTap;
  final List<ExploreTravelItem> travels;
  final bool isCameraReady;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    if (isTravelCreationMode) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: _detailHeaderTopOffset),
            child: Column(
              children: [
                AppDetailHeader(
                  title: '탐색',
                  onBack: onBackTap,
                  assetPackage: assetPackage,
                ),
                const SizedBox(height: _detailHeaderToContentGap),
                Expanded(child: _buildExploreContent()),
              ],
            ),
          ),
        ),
      );
    }

    return HomeScreen(
      initialTab: AppNavigationTab.explore,
      incompleteCount: incompleteCount,
      completeCount: completeCount,
      hasNotification: hasNotification,
      onNotificationTap: onNotificationTap,
      onWishTap: onWishTap,
      onMyPageTap: onMyPageTap,
      onCreateTravelTap: onCreateTravelTap,
      onJoinWithInviteCodeTap: onJoinWithInviteCodeTap,
      onNavigationChanged: onNavigationChanged,
      onPosongTap: onPosongTap,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      onSearchTap: onSearchTap,
      onRegionFilterTap: onRegionFilterTap,
      onDateFilterTap: onDateFilterTap,
      onCategoryFilterTap: onCategoryFilterTap,
      onFilterResetTap: onFilterResetTap,
      exploreTravels: travels,
      isCameraReady: isCameraReady,
      assetPackage: assetPackage,
    );
  }

  Widget _buildExploreContent() {
    return ExploreContent(
      travels: travels,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      onSearchTap: onSearchTap,
      onRegionFilterTap: onRegionFilterTap,
      onDateFilterTap: onDateFilterTap,
      onCategoryFilterTap: onCategoryFilterTap,
      onFilterResetTap: onFilterResetTap,
      assetPackage: assetPackage,
    );
  }
}

@Preview(group: 'hycho', name: 'Explore Screen', size: Size(393, 852))
Widget exploreScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreScreen(travels: explorePreviewTravels, assetPackage: 'pozit'),
  );
}

@Preview(group: 'haerim', name: '여행 생성 - 탐색', size: Size(393, 852))
Widget travelCreationExploreScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreScreen(
      isTravelCreationMode: true,
      travels: explorePreviewTravels,
      assetPackage: 'pozit',
    ),
  );
}
