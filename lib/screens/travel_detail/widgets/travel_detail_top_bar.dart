import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';
import 'travel_settings_popup.dart';
import 'travel_status.dart';

const double _kHeight = 56.0;
const double _kHorizontalPadding = 16.0;
const double _kTapTargetPadding = 10.0;
const double _kIconSize = 24.0;
const double _kLockTextGap = 13.0;
const double _kTitleSidePadding = 60.0;
const double _kIconTop = (_kHeight - _kIconSize) / 2;

const double _kTravelStatusWidth = 210.0;
const double _kTravelStatusHeight = 31.0;

/// 여행 상세 화면 전용 탑 바입니다.
///
/// [title]이 없으면 뒤로가기 버튼과 [travelStatusMode]만 표시하고,
/// [title]이 있으면 뒤로가기 버튼과 함께 중앙에 제목을, 필요에 따라
/// [showLock]으로 제목 앞 자물쇠 아이콘을, [showSettingsButton]으로
/// 오른쪽 끝 설정 버튼을 표시합니다.
class TravelDetailTopBar extends StatelessWidget {
  const TravelDetailTopBar({
    super.key,
    this.title,
    this.showLock = false,
    this.showSettingsButton = false,
    this.travelStatusMode,
    this.travelStatus,
    this.onBackTap,
    this.onSettingsTap,
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
       );

  /// 중앙에 표시할 제목. null이면 제목 대신 [travelStatusMode]가 표시됩니다.
  final String? title;

  /// 제목 앞에 자물쇠 아이콘을 표시할지 여부입니다.
  final bool showLock;

  /// 오른쪽 끝에 설정 버튼을 표시할지 여부입니다.
  final bool showSettingsButton;

  /// 오른쪽 끝에 표시할 여행 상태. 지정하면 [title]과 [showSettingsButton]은 무시됩니다.
  final TravelStatusMode? travelStatusMode;

  /// 설정 버튼을 눌렀을 때 뜨는 [TravelSettingsPopup]에 표시할 항목을 결정하는
  /// 여행 진행 상태입니다. [showSettingsButton]이 true이면 필수입니다.
  final AppTravelStatus? travelStatus;

  final VoidCallback? onBackTap;

  /// 설정 팝업의 '여행 설정' 항목을 눌렀을 때 호출됩니다.
  final VoidCallback? onSettingsTap;

  /// 설정 팝업의 '멤버' 항목을 눌렀을 때 호출됩니다.
  final VoidCallback? onMemberTap;

  /// 설정 팝업의 '여행 나가기' 항목을 눌렀을 때 호출됩니다.
  final VoidCallback? onLeaveTap;

  /// 설정 팝업의 '여행 삭제' 항목을 눌렀을 때 호출됩니다.
  final VoidCallback? onDeleteTap;

  /// 뒤로가기·설정·자물쇠 아이콘의 색상입니다.
  final Color iconColor;

  /// 제목 텍스트의 색상입니다.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                      style: AppTextStyles.headline.copyWith(color: textColor),
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
              child: SizedBox(
                width: _kTravelStatusWidth,
                height: _kTravelStatusHeight,
                child: TravelStatusIndicator(mode: travelStatusMode!),
              ),
            )
          else if (showSettingsButton)
            Positioned(
              right: _kHorizontalPadding - _kTapTargetPadding,
              top: _kIconTop - _kTapTargetPadding,
              child: _SettingsButton(
                iconColor: iconColor,
                travelStatus: travelStatus!,
                onSettingsTap: onSettingsTap,
                onMemberTap: onMemberTap,
                onLeaveTap: onLeaveTap,
                onDeleteTap: onDeleteTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton({
    required this.iconColor,
    required this.travelStatus,
    this.onSettingsTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
  });

  final Color iconColor;
  final AppTravelStatus travelStatus;
  final VoidCallback? onSettingsTap;
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
      onSettingsTap: widget.onSettingsTap,
      onMemberTap: widget.onMemberTap,
      onLeaveTap: widget.onLeaveTap,
      onDeleteTap: widget.onDeleteTap,
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
