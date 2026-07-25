import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/widgets/app_navigationbar.dart';
import '../home/home_screen.dart';

/// 여행지를 검색하고 탐색하는 화면입니다.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
    super.key,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onWishTap,
    this.onMyPageTap,
    this.onNavigationChanged,
    this.onPosongTap,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.onRegionFilterTap,
    this.onDateFilterTap,
    this.onCategoryFilterTap,
    this.onFilterResetTap,
    this.isCameraReady = false,
    this.assetPackage,
  });

  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWishTap;
  final VoidCallback? onMyPageTap;
  final ValueChanged<AppNavigationTab>? onNavigationChanged;
  final VoidCallback? onPosongTap;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onRegionFilterTap;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onCategoryFilterTap;
  final VoidCallback? onFilterResetTap;
  final bool isCameraReady;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      initialTab: AppNavigationTab.explore,
      hasNotification: hasNotification,
      onNotificationTap: onNotificationTap,
      onWishTap: onWishTap,
      onMyPageTap: onMyPageTap,
      onNavigationChanged: onNavigationChanged,
      onPosongTap: onPosongTap,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      onSearchTap: onSearchTap,
      onRegionFilterTap: onRegionFilterTap,
      onDateFilterTap: onDateFilterTap,
      onCategoryFilterTap: onCategoryFilterTap,
      onFilterResetTap: onFilterResetTap,
      isCameraReady: isCameraReady,
      assetPackage: assetPackage,
    );
  }
}

@Preview(group: 'hycho', name: 'Explore Screen', size: Size(393, 852))
Widget exploreScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreScreen(assetPackage: 'pozit'),
  );
}
