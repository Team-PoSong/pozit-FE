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
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItemData({
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// 여행 상태(전/중/후)에 따라 항목이 달라지는 여행 설정 팝업입니다.

class TravelSettingsPopup extends StatelessWidget {
  final AppTravelStatus status;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  const TravelSettingsPopup({
    super.key,
    required this.status,
    this.onSettingsTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
  });

  List<_MenuItemData> get _items {
    final settings = _MenuItemData(
      label: '여행 설정',
      color: AppColors.text,
      onTap: onSettingsTap,
    );
    final member = _MenuItemData(
      label: '멤버',
      color: AppColors.text,
      onTap: onMemberTap,
    );
    final leave = _MenuItemData(
      label: '여행 나가기',
      color: AppColors.text,
      onTap: onLeaveTap,
    );
    final delete = _MenuItemData(
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

  static const double _minWidth = 150.0;

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
                color: AppColors.white.withValues(alpha: 0.65),
                // 이 팝업은 Overlay.of(context).insert(...)로 Scaffold의
                // Material 밖(오버레이 레이어)에 직접 그려집니다. Material
                // 조상이 없으면 디버그 빌드에서 Text에 노란 밑줄 경고가
                // 붙으므로, transparency 타입의 Material로 감싸 해결합니다.
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
        child: Text(data.label, style: AppTextStyles.body.copyWith(color: data.color)),
      ),
    );
  }
}

/// 여행 설정 팝업을 [anchorLink]가 붙은 트리거 버튼(설정 아이콘) 바로 아래에 띄웁니다.
///
/// 호출하는 쪽에서는 트리거 버튼을 `CompositedTransformTarget(link: anchorLink, ...)`
/// 로 감싸두면, 팝업의 오른쪽 상단 모서리가 트리거의 오른쪽 하단 모서리에
/// 맞춰집니다.
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
  AnimationController? controller;

  Future<void> close() async {
    await controller?.reverse();
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
          // 트리거(설정 아이콘)의 오른쪽 하단 모서리에 팝업의 오른쪽 상단
          // 모서리를 붙여서, 팝업이 트리거 바로 아래에 오도록 합니다.
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(-10, 0),
          child: _PopupTransition(
            onControllerReady: (c) => controller = c,
            child: TravelSettingsPopup(
              status: status,
              onSettingsTap: wrap(onSettingsTap),
              onMemberTap: wrap(onMemberTap),
              onLeaveTap: wrap(onLeaveTap),
              onDeleteTap: wrap(onDeleteTap),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
  return completer.future;
}

/// 팝업이 앵커(오른쪽 상단, 설정 아이콘 위치)를 기준으로 페이드인+스케일업 되며
/// 나타나도록 감싸는 위젯입니다.
class _PopupTransition extends StatefulWidget {
  const _PopupTransition({required this.child, required this.onControllerReady});

  final Widget child;
  final ValueChanged<AnimationController> onControllerReady;

  @override
  State<_PopupTransition> createState() => _PopupTransitionState();
}

class _PopupTransitionState extends State<_PopupTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  ).drive(Tween<double>(begin: 0.9, end: 1.0));

  @override
  void initState() {
    super.initState();
    widget.onControllerReady(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.topRight,
        child: widget.child,
      ),
    );
  }
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
