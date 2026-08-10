import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

class AppDetailHeader extends StatelessWidget {
  const AppDetailHeader({
    super.key,
    required this.title,
    this.onBack,
    this.assetPackage,
  });

  final String title;
  final VoidCallback? onBack;
  final String? assetPackage;

  static const double _headerHeight = 53.0;
  static const double _backTapAreaLeft = 12.0;
  static const double _titleHorizontalInset =
      _backTapAreaLeft + AppDimensions.minimumTapTargetSize;
  static const double _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _titleHorizontalInset,
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(color: AppColors.text),
            ),
          ),
          Positioned(
            left: _backTapAreaLeft,
            child: Semantics(
              button: true,
              label: '뒤로가기',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack ?? () => Navigator.maybePop(context),
                child: SizedBox.square(
                  dimension: AppDimensions.minimumTapTargetSize,
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.arrowLeft,
                      package: assetPackage,
                      width: _iconSize,
                      height: _iconSize,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: '상세 헤더', size: Size(393, 61))
Widget appDetailHeaderPreview() => const MaterialApp(
  home: Scaffold(
    body: SafeArea(child: AppDetailHeader(title: '내 정보')),
  ),
);
