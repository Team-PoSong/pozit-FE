import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app_colors.dart';
import '../../app_icons.dart';
import '../../app_text_styles.dart';

enum AppButtonStyle { filled, tonal }

class AppButton extends StatelessWidget {
  final String text;
  final AppButtonStyle style;
  final bool isEnabled;
  final bool isActive;
  final VoidCallback? onPressed;
  final String? iconAsset;
  final double iconWidth;
  final double iconHeight;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double borderRadius;
  final double iconGap;
  final Color? contentColor;
  final Color? backgroundColor;
  final Color? disabledContentColor;
  final Color? disabledBackgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.style = AppButtonStyle.filled,
    this.isEnabled = true,
    this.isActive = true,
    this.onPressed,
    this.iconAsset,
    this.iconWidth = 16.0,
    this.iconHeight = 16.0,
    this.textStyle,
    this.padding = const EdgeInsets.only(top: 18, bottom: 19),
    this.width,
    this.borderRadius = 12.0,
    this.iconGap = 6.0,
    this.contentColor,
    this.backgroundColor,
    this.disabledContentColor,
    this.disabledBackgroundColor,
  });

  static const TextStyle _defaultTextStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 25 / 18,
  );

  bool get _isTappable => isEnabled;

  Color get _backgroundColor {
    if (!isEnabled) return disabledBackgroundColor ?? AppColors.gray3;
    if (!isActive) return AppColors.gray3;
    if (backgroundColor != null) return backgroundColor!;
    return style == AppButtonStyle.filled
        ? AppColors.primary
        : AppColors.purple1;
  }

  Color get _contentColor {
    if (!isEnabled) return disabledContentColor ?? AppColors.gray5;
    if (!isActive) return AppColors.gray5;
    if (contentColor != null) return contentColor!;
    return style == AppButtonStyle.filled ? AppColors.white : AppColors.purple3;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isTappable ? onPressed : null,
      child: Container(
        width: width ?? double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null) ...[
              SvgPicture.asset(
                iconAsset!,
                width: iconWidth,
                height: iconHeight,
              ),
              SizedBox(width: iconGap),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: (textStyle ?? _defaultTextStyle).copyWith(
                  color: _contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppFavoriteButton extends StatelessWidget {
  const AppFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '찜하기',
      isEnabled: onPressed != null,
      style: AppButtonStyle.tonal,
      backgroundColor: isFavorite ? AppColors.gray3 : AppColors.purple1,
      contentColor: isFavorite ? AppColors.gray5 : AppColors.purple3,
      iconAsset: isFavorite ? AppIcons.heartMiddleGray : AppIcons.heartMiddle,
      iconWidth: 24,
      iconHeight: 24,
      iconGap: 14,
      onPressed: onPressed,
    );
  }
}

@Preview(group: 'haerim', name: 'AppButton - 다음 활성')
Widget appButtonNextEnabledPreview() =>
    const AppButton(text: '다음', isEnabled: true);

@Preview(group: 'haerim', name: 'AppButton - 다음 비활성')
Widget appButtonNextDisabledPreview() =>
    const AppButton(text: '다음', isEnabled: false);

class _LikeButtonDemo extends StatefulWidget {
  const _LikeButtonDemo();

  @override
  State<_LikeButtonDemo> createState() => _LikeButtonDemoState();
}

class _LikeButtonDemoState extends State<_LikeButtonDemo> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return AppFavoriteButton(
      isFavorite: _isActive,
      onPressed: () => setState(() => _isActive = !_isActive),
    );
  }
}

@Preview(group: 'haerim', name: 'AppButton - 찜하기')
Widget appButtonLikePreview() => const _LikeButtonDemo();

@Preview(group: 'haerim', name: 'AppButton - 챗봇 적용하기')
Widget appButtonChatbotApplyPreview() => const AppButton(
  text: '적용하기',
  width: 224.0,
  padding: EdgeInsets.symmetric(vertical: 7.0),
  borderRadius: 4.0,
  textStyle: AppTextStyles.body,
);

@Preview(group: 'haerim', name: 'AppButton - 코스 수정하기')
Widget appButtonEditCourseEnabledPreview() => const AppButton(
  text: '코스 수정하기',
  style: AppButtonStyle.tonal,
  contentColor: AppColors.text,
  isEnabled: true,
);

@Preview(group: 'haerim', name: 'AppButton - 필터')
Widget appButtonFilterPreview() => const AppButton(
  text: '필터',
  width: 73.0,
  backgroundColor: AppColors.purple3,
  iconAsset: AppIcons.filter,
  iconWidth: 20.0,
  iconHeight: 20.0,
  iconGap: 8.0,
  padding: EdgeInsets.symmetric(vertical: 3.0),
  borderRadius: 999.0,
  textStyle: AppTextStyles.body,
);
