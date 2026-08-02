import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';

const double _kHorizontalPadding = 78.0;
const double _kTopToHeaderGap = 58.0;
const double _kTextToTicketGap = 9.0;
const double _kTicketWidth = 59.0;
const double _kTicketHeight = 89.0;
const double _kHeaderToLogGap = 29.0;
const double _kLogBlockAspectRatio = 236 / 421;
const double _kLogBlockRadius = 12.0;
const double _kButtonsBottomGap = 37.0;
const double _kButtonGap = 54.0;
const double _kButtonCircleSize = 60.0;
const double _kButtonBorderWidth = 1.0;
const double _kButtonIconSize = 30.0;
const double _kButtonIconToLabelGap = 13.0;

class TravelLogCompleteScreen extends StatelessWidget {
  const TravelLogCompleteScreen({
    super.key,
    required this.travelName,
    this.onCancelTap,
    this.onSaveTap,
    this.onShareTap,
  });

  final String travelName;
  final VoidCallback? onCancelTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.travelLogGradientStart,
                AppColors.travelLogGradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: _kTopToHeaderGap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '$travelName의 추억이 담긴\n여행 로그가 저장되었어요!',
                            style: AppTextStyles.subTitle.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _kTextToTicketGap),
                      Image.asset(
                        AppImages.carrierTicket,
                        width: _kTicketWidth,
                        height: _kTicketHeight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _kHeaderToLogGap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: AspectRatio(
                    aspectRatio: _kLogBlockAspectRatio,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(_kLogBlockRadius),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LogActionButton(
                      icon: AppIcons.x,
                      label: '취소',
                      onTap: onCancelTap,
                    ),
                    const SizedBox(width: _kButtonGap),
                    _LogActionButton(
                      icon: AppIcons.save,
                      label: '저장',
                      onTap: onSaveTap,
                    ),
                    const SizedBox(width: _kButtonGap),
                    _LogActionButton(
                      icon: AppIcons.share,
                      label: '공유',
                      onTap: onShareTap,
                    ),
                  ],
                ),
                SizedBox(
                  height: _kButtonsBottomGap + MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogActionButton extends StatelessWidget {
  const _LogActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: AppColors.white,
            shape: const CircleBorder(
              side: BorderSide(
                color: AppColors.gray3,
                width: _kButtonBorderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: _kButtonCircleSize,
                height: _kButtonCircleSize,
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: _kButtonIconSize,
                    height: _kButtonIconSize,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: _kButtonIconToLabelGap),
        Text(
          label,
          style: AppTextStyles.caption2.copyWith(color: AppColors.gray5),
        ),
      ],
    );
  }
}

@Preview(
  group: 'travel_log',
  name: 'TravelLogCompleteScreen',
  size: Size(390, 844),
)
Widget travelLogCompleteScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelLogCompleteScreen(travelName: '경주여행'),
  );
}
