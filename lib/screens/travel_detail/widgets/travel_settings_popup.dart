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

class TravelSettingsPopup extends StatelessWidget {
  final AppTravelStatus status;
  final bool isLeader;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCourseEditTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;

  const TravelSettingsPopup({
    super.key,
    required this.status,
    required this.isLeader,
    this.onSettingsTap,
    this.onCourseEditTap,
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
    final courseEdit = _MenuItemData(
      label: '코스 수정',
      color: AppColors.text,
      onTap: onCourseEditTap,
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

    if (!isLeader) return [member, leave];

    switch (status) {
      case AppTravelStatus.upcoming:
      case AppTravelStatus.inProgress:
        return [settings, courseEdit, member, delete];
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

Future<void> showTravelSettingsPopup(
  BuildContext context, {
  required LayerLink anchorLink,
  required AppTravelStatus status,
  required bool isLeader,
  VoidCallback? onSettingsTap,
  VoidCallback? onCourseEditTap,
  VoidCallback? onMemberTap,
  VoidCallback? onLeaveTap,
  VoidCallback? onDeleteTap,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late final OverlayEntry entry;
  AnimationController? controller;
  var isClosing = false;

  Future<void> close() async {
    if (isClosing) return;
    isClosing = true;
    await controller?.reverse();
    entry.remove();
    completer.complete();
  }

  VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      close().then((_) => callback());
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
          offset: const Offset(-10, 0),
          child: _PopupTransition(
            onControllerReady: (c) => controller = c,
            child: TravelSettingsPopup(
              status: status,
              isLeader: isLeader,
              onSettingsTap: wrap(onSettingsTap),
              onCourseEditTap: wrap(onCourseEditTap),
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
  final bool isLeader;

  const _TravelSettingsPopupPreview({
    required this.status,
    required this.isLeader,
  });

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
        isLeader: widget.isLeader,
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

Widget _popupPreview(AppTravelStatus status, {required bool isLeader}) {
  return MaterialApp(
    home: _TravelSettingsPopupPreview(status: status, isLeader: isLeader),
  );
}

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀장 - 여행 전', size: Size(390, 844))
Widget travelSettingsPopupUpcomingPreview() =>
    _popupPreview(AppTravelStatus.upcoming, isLeader: true);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀장 - 여행 중', size: Size(390, 844))
Widget travelSettingsPopupInProgressPreview() =>
    _popupPreview(AppTravelStatus.inProgress, isLeader: true);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀장 - 여행 후', size: Size(390, 844))
Widget travelSettingsPopupCompletedPreview() =>
    _popupPreview(AppTravelStatus.completed, isLeader: true);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀원 - 여행 전', size: Size(390, 844))
Widget travelSettingsPopupMemberUpcomingPreview() =>
    _popupPreview(AppTravelStatus.upcoming, isLeader: false);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀원 - 여행 중', size: Size(390, 844))
Widget travelSettingsPopupMemberInProgressPreview() =>
    _popupPreview(AppTravelStatus.inProgress, isLeader: false);

@Preview(group: 'Seohyun', name: 'TravelSettingsPopup - 팀원 - 여행 후', size: Size(390, 844))
Widget travelSettingsPopupMemberCompletedPreview() =>
    _popupPreview(AppTravelStatus.completed, isLeader: false);
