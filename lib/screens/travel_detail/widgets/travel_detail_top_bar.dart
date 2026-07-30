import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';
import '../../../core/design_system/widgets/app_confirm_dialog.dart';
import 'travel_settings_popup.dart';
import 'travel_status.dart';

const double _kHeight = 56.0;

const double _kTopOffset = 4.0;
const double _kHorizontalPadding = 16.0;
const double _kTapTargetPadding = 10.0;
const double _kIconSize = 24.0;
const double _kLockTextGap = 13.0;
const double _kTitleSidePadding = 60.0;
const double _kIconTop = (_kHeight - _kIconSize) / 2;

class TravelDetailTopBar extends StatelessWidget {
  const TravelDetailTopBar({
    super.key,
    this.title,
    this.showLock = false,
    this.showSettingsButton = false,
    this.travelStatusMode,
    this.travelStatus,
    this.isLeader,
    this.onBackTap,
    this.onSettingsTap,
    this.onCourseEditTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
    this.iconColor = AppColors.text,
    this.textColor = AppColors.text,
  }) : assert(
         travelStatusMode == null || !showSettingsButton,
         'travelStatusMode와 showSettingsButton은 동시에 사용할 수 없습니다.',
       ),
       assert(
         !showSettingsButton || travelStatus != null,
         'showSettingsButton이 true면 travelStatus가 필요합니다.',
       ),
       assert(
         !showSettingsButton || isLeader != null,
         'showSettingsButton이 true면 isLeader가 필요합니다.',
       );

  final String? title;

  final bool showLock;

  final bool showSettingsButton;

  final TravelStatusMode? travelStatusMode;

  final AppTravelStatus? travelStatus;

  final bool? isLeader;

  final VoidCallback? onBackTap;

  final VoidCallback? onSettingsTap;

  final VoidCallback? onCourseEditTap;

  final VoidCallback? onMemberTap;

  final VoidCallback? onLeaveTap;

  final VoidCallback? onDeleteTap;

  final Color iconColor;

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _kTopOffset),
      child: SizedBox(
        width: double.infinity,
        height: _kHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kTitleSidePadding,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showLock) ...[
                      SvgPicture.asset(
                        AppIcons.lockClosed,
                        width: _kIconSize,
                        height: _kIconSize,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: _kLockTextGap),
                    ],
                    Flexible(
                      child: Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headline.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              left: _kHorizontalPadding - _kTapTargetPadding,
              top: _kIconTop - _kTapTargetPadding,
              child: _IconButton(
                icon: AppIcons.arrowLeft,
                iconColor: iconColor,
                onTap: onBackTap,
              ),
            ),
            if (travelStatusMode != null)
              Positioned(
                right: _kHorizontalPadding,
                top: _kIconTop,
                child: TravelStatusIndicator(mode: travelStatusMode!),
              )
            else if (showSettingsButton)
              Positioned(
                right: _kHorizontalPadding - _kTapTargetPadding,
                top: _kIconTop - _kTapTargetPadding,
                child: _SettingsButton(
                  iconColor: iconColor,
                  travelStatus: travelStatus!,
                  isLeader: isLeader!,
                  onSettingsTap: onSettingsTap,
                  onCourseEditTap: onCourseEditTap,
                  onMemberTap: onMemberTap,
                  onLeaveTap: onLeaveTap,
                  onDeleteTap: onDeleteTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton({
    required this.iconColor,
    required this.travelStatus,
    required this.isLeader,
    this.onSettingsTap,
    this.onCourseEditTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
  });

  final Color iconColor;
  final AppTravelStatus travelStatus;
  final bool isLeader;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCourseEditTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  final LayerLink _anchorLink = LayerLink();

  void _handleTap() {
    showTravelSettingsPopup(
      context,
      anchorLink: _anchorLink,
      status: widget.travelStatus,
      isLeader: widget.isLeader,
      onSettingsTap: widget.onSettingsTap,
      onCourseEditTap: widget.onCourseEditTap,
      onMemberTap: widget.onMemberTap,
      onLeaveTap: _handleLeaveTap,
      onDeleteTap: _handleDeleteTap,
    );
  }

  void _handleLeaveTap() {
    showAppConfirmDialog(
      context,
      title: '여행을 나가겠습니까?',
      description: '해당 작업은 돌릴 수 없습니다.',
      confirmText: '나가기',
      onConfirm: widget.onLeaveTap,
    );
  }

  void _handleDeleteTap() {
    showAppConfirmDialog(
      context,
      title: '여행을 삭제하겠습니까?',
      description: '해당 작업은 돌릴 수 없습니다.',
      confirmText: '삭제하기',
      onConfirm: widget.onDeleteTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _anchorLink,
      child: _IconButton(
        icon: AppIcons.more,
        iconColor: widget.iconColor,
        onTap: _handleTap,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(_kTapTargetPadding),
        child: SvgPicture.asset(
          icon,
          width: _kIconSize,
          height: _kIconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}

@Preview(group: 'travel_detail', name: 'TopBar - 텍스트만')
Widget travelDetailTopBarTitleOnlyPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailTopBar(title: '여행 설정'),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TopBar - 설정 버튼')
Widget travelDetailTopBarWithSettingsPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailTopBar(
        title: '경주 여행!!',
        showSettingsButton: true,
        travelStatus: AppTravelStatus.upcoming,
        isLeader: true,
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TopBar - 자물쇠 + 설정 버튼')
Widget travelDetailTopBarWithLockPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailTopBar(
        title: '경주 여행!!',
        showLock: true,
        showSettingsButton: true,
        travelStatus: AppTravelStatus.completed,
        isLeader: true,
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TopBar - 여행 상태')
Widget travelDetailTopBarWithStatusPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailTopBar(travelStatusMode: TravelStatusMode.traveling),
    ),
  );
}
