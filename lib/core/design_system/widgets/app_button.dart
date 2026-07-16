import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

// 공통 버튼을 정의합니다.
// 버튼 색상 스타일: filled-진한 색상 배경, tonal-연한 색상 배경

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
  });

  static const TextStyle _defaultTextStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 25 / 18,
  );

  bool get _isTappable => isEnabled;

  Color get _backgroundColor {
    if (!isEnabled || !isActive) return AppColors.gray3;
    if (backgroundColor != null) return backgroundColor!;
    return style == AppButtonStyle.filled
        ? AppColors.primary
        : AppColors.purple1;
  }

  Color get _contentColor {
    if (!isEnabled || !isActive) return AppColors.gray5;
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
                colorFilter: ColorFilter.mode(_contentColor, BlendMode.srcIn),
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

class AppChatbotButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const AppChatbotButton({
    super.key,
    this.onPressed,
    this.width = 38.0,
    this.height = 31.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            SvgPicture.asset(
              AppIcons.chatBubble,
              width: width,
              height: height,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13.0, 5.0, 13.0, 12.0),
                child: Center(
                  child: Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      height: 14 / 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 원형 아이콘 버튼
/// 기본 생성자: 진보라 배경(+버튼) 스타일
/// .outline 생성자: 흰 배경+회색 테두리 스타일
class AppCircleButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;

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

  const AppCircleButton.outline({
    super.key,
    required this.iconAsset,
    this.onPressed,
    this.size = 60.0,
    this.iconSize = 24.0,
  })  : backgroundColor = AppColors.white,
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
          border: borderColor != null ? Border.all(color: borderColor!, width: 1.0) : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              iconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// "다음" 버튼
@Preview(group: 'haerim', name: 'AppButton - 다음 활성')
Widget appButtonNextEnabledPreview() =>
    const AppButton(text: '다음', isEnabled: true);

@Preview(group: 'haerim', name: 'AppButton - 다음 비활성')
Widget appButtonNextDisabledPreview() =>
    const AppButton(text: '다음', isEnabled: false);

/// "찜하기" 버튼 - 누를 때마다 활성(보라)/비활성(회색) 토글되는 걸 눈으로 확인하는 데모.
class _LikeButtonDemo extends StatefulWidget {
  const _LikeButtonDemo();

  @override
  State<_LikeButtonDemo> createState() => _LikeButtonDemoState();
}

class _LikeButtonDemoState extends State<_LikeButtonDemo> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '찜하기',
      style: AppButtonStyle.tonal,
      isActive: _isActive,
      iconAsset: AppIcons.heartBig,
      iconWidth: 24.0,
      iconHeight: 24.0,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      iconGap: 11.0,
      textStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
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

// "코스 수정하기" 버튼
@Preview(group: 'haerim', name: 'AppButton - 코스 수정하기')
Widget appButtonEditCourseEnabledPreview() => const AppButton(
  text: '코스 수정하기',
  style: AppButtonStyle.tonal,
  contentColor: AppColors.text,
  isEnabled: true,
);

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

@Preview(group: 'haerim', name: 'AppChatbotButton')
Widget appChatbotButtonPreview() => const AppChatbotButton();