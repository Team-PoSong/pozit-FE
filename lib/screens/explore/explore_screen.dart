import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/widgets/app_navigationbar.dart';
import '../home/home_screen.dart';
import 'explore_content.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
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
}

@Preview(group: 'hycho', name: 'Explore Screen', size: Size(393, 852))
Widget exploreScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreScreen(
      travels: explorePreviewTravels,
      assetPackage: 'pozit',
    ),
  );
}
