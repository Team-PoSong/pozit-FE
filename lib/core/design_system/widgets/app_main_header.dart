import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_icons.dart';
import '../app_images.dart';

class AppMainHeader extends StatelessWidget {
  const AppMainHeader({
    super.key,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onWishTap,
    this.onMyPageTap,
    this.assetPackage,
  });

  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWishTap;
  final VoidCallback? onMyPageTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, right: 18),
      child: Row(
        children: [
          Image.asset(
            AppImages.miniLogo,
            package: assetPackage,
            width: 70,
            height: 32,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _HeaderAction(
            semanticLabel: '알림',
            iconAsset: hasNotification
                ? AppIcons.hasNotification
                : AppIcons.noNotification,
            assetPackage: assetPackage,
            onTap: onNotificationTap,
          ),
          _HeaderAction(
            semanticLabel: '찜 목록',
            iconAsset: AppIcons.headerHeart,
            assetPackage: assetPackage,
            onTap: onWishTap,
          ),
          _HeaderAction(
            semanticLabel: '마이페이지',
            iconAsset: AppIcons.mypage,
            assetPackage: assetPackage,
            onTap: onMyPageTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.semanticLabel,
    required this.iconAsset,
    required this.assetPackage,
    required this.onTap,
  });

  final String semanticLabel;
  final String iconAsset;
  final String? assetPackage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              package: assetPackage,
              width: 24,
              height: 24,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'App Main Header', size: Size(393, 100))
Widget appMainHeaderPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: SafeArea(child: AppMainHeader(assetPackage: 'pozit')),
    ),
  );
}
