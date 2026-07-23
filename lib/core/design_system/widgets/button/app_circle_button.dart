import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app_colors.dart';
import '../../app_icons.dart';

class AppCircleButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;

  /// 진보라 배경 스타일
  const AppCircleButton({
    super.key,
    this.iconAsset = AppIcons.plus,
    this.onPressed,
    this.size = 42.0,
    this.iconSize = 24.0,
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.borderColor,
  });

  /// 흰 배경+회색 테두리 스타일
  const AppCircleButton.outline({
    super.key,
    required this.iconAsset,
    this.onPressed,
    this.size = 60.0,
    this.iconSize = 24.0,
  }) : backgroundColor = AppColors.white,
        iconColor = AppColors.text,
        borderColor = AppColors.gray3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.0)
              : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppCircleButton - +')
Widget appCircleButtonPreview() => const AppCircleButton();

@Preview(group: 'haerim', name: 'AppCircleButton - X')
Widget appCircleButtonClosePreview() =>
    const AppCircleButton.outline(iconAsset: AppIcons.close);

@Preview(group: 'haerim', name: 'AppCircleButton - 저장')
Widget appCircleButtonSavePreview() =>
    const AppCircleButton.outline(iconAsset: AppIcons.save);

@Preview(group: 'haerim', name: 'AppCircleButton - 공유')
Widget appCircleButtonSharePreview() =>
    const AppCircleButton.outline(iconAsset: AppIcons.share);