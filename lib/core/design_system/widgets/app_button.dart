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
  final bool isLoading; // true면 회색으로 바뀌고 탭 막힘 (비활성과 동일한 시각 효과)
  final bool isActive; // 찜하기처럼 "켜짐/꺼짐" 토글용. false면 회색이지만 탭은 계속 가능
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
    this.isLoading = false,
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

  bool get _isTappable => isEnabled && !isLoading;

  Color get _backgroundColor {
    if (!isEnabled || isLoading || !isActive) return AppColors.gray3;
    if (backgroundColor != null) return backgroundColor!;
    return style == AppButtonStyle.filled
        ? AppColors.primary
        : AppColors.purple1;
  }

  Color get _contentColor {
    if (!isEnabled || isLoading || !isActive) return AppColors.gray5;
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
            Text(
              text,
              style: (textStyle ?? _defaultTextStyle).copyWith(
                color: _contentColor,
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

class AppCircleButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  const AppCircleButton({
    super.key,
    this.iconAsset = AppIcons.plus,
    this.onPressed,
    this.size = 42.0,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// "다음" 버튼 - 누르면 로딩(비활성과 동일한 회색)으로 바뀌는 데모.
/// 한 번 로딩 상태가 되면(isLoading: true) AppButton 내부에서 탭을 막음
class _NextButtonDemo extends StatefulWidget {
  const _NextButtonDemo();

  @override
  State<_NextButtonDemo> createState() => _NextButtonDemoState();
}

class _NextButtonDemoState extends State<_NextButtonDemo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '다음',
      isLoading: _isLoading,
      onPressed: () => setState(() => _isLoading = true),
    );
  }
}

@Preview(group: 'haerim', name: 'AppButton - 다음')
Widget appButtonNextPreview() => const _NextButtonDemo();

/// "찜하기" 버튼 - 누를 때마다 활성(보라)/비활성(회색) 토글됨
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

/// "코스 수정하기" 버튼 - "다음" 버튼과 동일하게 한 번 로딩 상태가 되면 되돌아오지 않음.
class _EditCourseButtonDemo extends StatefulWidget {
  const _EditCourseButtonDemo();

  @override
  State<_EditCourseButtonDemo> createState() => _EditCourseButtonDemoState();
}

class _EditCourseButtonDemoState extends State<_EditCourseButtonDemo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '코스 수정하기',
      style: AppButtonStyle.tonal,
      contentColor: AppColors.text,
      isLoading: _isLoading,
      onPressed: () => setState(() => _isLoading = true),
    );
  }
}

@Preview(group: 'haerim', name: 'AppButton - 코스 수정하기')
Widget appButtonEditCoursePreview() => const _EditCourseButtonDemo();

@Preview(group: 'haerim', name: 'AppCircleButton - +버튼')
Widget appCircleButtonPreview() => const AppCircleButton();

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