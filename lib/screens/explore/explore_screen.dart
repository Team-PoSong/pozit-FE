import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_bottom_gradient.dart';
import '../../core/design_system/widgets/app_main_header.dart';
import '../../core/design_system/widgets/app_navigationbar.dart';
import '../../core/design_system/widgets/app_search_bar.dart';

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
  final bool isCameraReady;
  final String? assetPackage;

  void _handleNavigationChanged(BuildContext context, AppNavigationTab tab) {
    if (onNavigationChanged != null) {
      onNavigationChanged?.call(tab);
      return;
    }

    if (tab == AppNavigationTab.travel && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: SizedBox(
        height: AppBottomGradient.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: AppBottomGradient()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppNavigationBar(
                selectedTab: AppNavigationTab.explore,
                onChanged: (tab) => _handleNavigationChanged(context, tab),
                onPosongTap: onPosongTap,
                isCameraReady: isCameraReady,
                assetPackage: assetPackage,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppMainHeader(
              hasNotification: hasNotification,
              onNotificationTap: onNotificationTap,
              onWishTap: onWishTap,
              onMyPageTap: onMyPageTap,
              assetPackage: assetPackage,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppSearchBar(
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted,
                onSearchTap: onSearchTap,
              ),
            ),
          ],
        ),
      ),
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
