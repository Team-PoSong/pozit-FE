import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';

class _MenuItemData {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// 여행 상태(전/중/후)에 따라 항목이 달라지는 여행 설정 팝업입니다.

class TravelSettingsPopup extends StatelessWidget {
  final AppTravelStatus status;
  final VoidCallback? onClose;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  const TravelSettingsPopup({
    super.key,
    required this.status,
    this.onClose,
    this.onSettingsTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
  });

  List<_MenuItemData> get _items {
    final settings = _MenuItemData(
      icon: AppIcons.travelLuggage,
      label: '여행 설정',
      color: AppColors.text,
      onTap: onSettingsTap,
    );
    final member = _MenuItemData(
      icon: AppIcons.group,
      label: '멤버',
      color: AppColors.text,
      onTap: onMemberTap,
    );
    final leave = _MenuItemData(
      icon: AppIcons.exit,
      label: '여행 나가기',
      color: AppColors.text,
      onTap: onLeaveTap,
    );
    final delete = _MenuItemData(
      icon: AppIcons.trash,
      label: '여행 삭제',
      color: AppColors.error,
      onTap: onDeleteTap,
    );

    switch (status) {
      case AppTravelStatus.upcoming:
        return [settings, member, delete];
      case AppTravelStatus.inProgress:
        return [leave, member];
      case AppTravelStatus.completed:
        return [settings, member, leave];
    }
  }

  static const double _minWidth = 213.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: _minWidth),
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.popoverShadow,
                blurRadius: 12.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: AppColors.white.withValues(alpha: 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _CloseButton(onTap: onClose),
                    ),
                    for (var i = 0; i < _items.length; i++) ...[
                      if (i > 0) const _PopupDivider(),
                      _PopupMenuRow(data: _items[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 11.0, left: 11.0),
        child: SvgPicture.asset(AppIcons.close, width: 24.0, height: 24.0),
      ),
    );
  }
}

class _PopupDivider extends StatelessWidget {
  const _PopupDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 0.5, thickness: 0.5, color: AppColors.gray4),
    );
  }
}

class _PopupMenuRow extends StatelessWidget {
  final _MenuItemData data;

  const _PopupMenuRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(data.icon, width: 24.0, height: 24.0),
            const SizedBox(width: 18.0),
            Text(data.label, style: AppTextStyles.body.copyWith(color: data.color)),
          ],
        ),
      ),
    );
  }
}

/// 여행 설정 팝업을 [anchorLink]가 붙은 트리거 버튼 바로 아래에 띄웁니다.
///
/// 호출하는 쪽에서는 트리거 버튼을 `CompositedTransformTarget(link: anchorLink, ...)`
/// 로 감싸두면, 팝업이 그 버튼의 실제 레이아웃 위치를 기준으로 따라붙습니다.
Future<void> showTravelSettingsPopup(
  BuildContext context, {
  required LayerLink anchorLink,
  required AppTravelStatus status,
  VoidCallback? onSettingsTap,
  VoidCallback? onMemberTap,
  VoidCallback? onLeaveTap,
  VoidCallback? onDeleteTap,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  void close() {
    entry.remove();
    completer.complete();
  }

  VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      close();
      callback();
    };
  }

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: close,
          ),
        ),
        CompositedTransformFollower(
          link: anchorLink,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          child: TravelSettingsPopup(
            status: status,
            onClose: close,
            onSettingsTap: wrap(onSettingsTap),
            onMemberTap: wrap(onMemberTap),
            onLeaveTap: wrap(onLeaveTap),
            onDeleteTap: wrap(onDeleteTap),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
  return completer.future;
}

class _TravelSettingsPopupPreview extends StatefulWidget {
  final AppTravelStatus status;

  const _TravelSettingsPopupPreview({required this.status});

  @override
  State<_TravelSettingsPopupPreview> createState() =>
      _TravelSettingsPopupPreviewState();
}

class _TravelSettingsPopupPreviewState
    extends State<_TravelSettingsPopupPreview> {
  final _anchorLink = LayerLink();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showTravelSettingsPopup(
        context,
        anchorLink: _anchorLink,
        status: widget.status,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          CompositedTransformTarget(
            link: _anchorLink,
            child: IconButton(
              icon: SvgPicture.asset(
                AppIcons.more,
                width: 24.0,
                height: 24.0,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Image.asset(
        AppImages.travelMockup,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

Widget _popupPreview(AppTravelStatus status) {
  return MaterialApp(home: _TravelSettingsPopupPreview(status: status));
}

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 여행 전', size: Size(390, 844))
Widget travelSettingsPopupUpcomingPreview() =>
    _popupPreview(AppTravelStatus.upcoming);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 여행 중', size: Size(390, 844))
Widget travelSettingsPopupInProgressPreview() =>
    _popupPreview(AppTravelStatus.inProgress);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 여행 후', size: Size(390, 844))
Widget travelSettingsPopupCompletedPreview() =>
    _popupPreview(AppTravelStatus.completed);
