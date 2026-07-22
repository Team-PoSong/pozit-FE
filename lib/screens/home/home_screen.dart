import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_main_header.dart';
import '../../core/design_system/widgets/app_top_navigate_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.incompleteCount = 0,
    this.completeCount = 1,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onWishTap,
    this.onMyPageTap,
    this.onCreateTravelTap,
    this.assetPackage,
  });

  final int incompleteCount;
  final int completeCount;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWishTap;
  final VoidCallback? onMyPageTap;
  final VoidCallback? onCreateTravelTap;
  final String? assetPackage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTopNavigateTab _selectedTab = AppTopNavigateTab.incomplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          AppMainHeader(
            hasNotification: widget.hasNotification,
            onNotificationTap: widget.onNotificationTap,
            onWishTap: widget.onWishTap,
            onMyPageTap: widget.onMyPageTap,
            assetPackage: widget.assetPackage,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTopNavigateBar(
                    incompleteCount: widget.incompleteCount,
                    completeCount: widget.completeCount,
                    selectedTab: _selectedTab,
                    onChanged: (tab) {
                      setState(() => _selectedTab = tab);
                    },
                  ),
                ),
                const SizedBox(width: 11),
                Semantics(
                  button: true,
                  label: '여행 만들기',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onCreateTravelTap,
                    child: DecoratedBox(
                      decoration: const ShapeDecoration(
                        color: AppColors.purple3,
                        shape: CircleBorder(),
                      ),
                      child: SizedBox.square(
                        dimension: 43,
                        child: Center(
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
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: const Alignment(0, -0.25),
              child: Column(
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
                    style: AppTextStyles.body.copyWith(color: AppColors.gray5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Home Screen', size: Size(393, 852))
Widget homeScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(assetPackage: 'pozit'),
  );
}
