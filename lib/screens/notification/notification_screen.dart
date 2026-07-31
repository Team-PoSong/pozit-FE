import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_content.dart';

const double _kTopBarTopOffset = 4.0;
const double _kTopBarHeight = 56.0;
const double _kTopBarHorizontalPadding = 16.0;
const double _kTopBarTitleSidePadding = 60.0;
const double _kBackIconSize = 24.0;
const double _kErrorHorizontalPadding = 24.0;
const double _kErrorMessageToRetryGap = 16.0;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    this.onBackTap,
    this.initialNotifications,
    NotificationRepository? repository,
  }) : repository = repository ?? const NotificationRepository();

  final VoidCallback? onBackTap;
  final List<NotificationModel>? initialNotifications;
  final NotificationRepository repository;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel>? _notifications;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _notifications = widget.initialNotifications;
    if (_notifications == null) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _error = null);

    try {
      final notifications = await widget.repository.getNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  void _handleBack() {
    if (widget.onBackTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: _kTopBarTopOffset),
          child: Column(
            children: [
              NotificationTopBar(onBackTap: _handleBack),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error case final error?) {
      final message = error is ApiException ? error.message : '알림을 불러오지 못했습니다.';
      return _NotificationError(message: message, onRetry: _loadNotifications);
    }

    if (_notifications case final notifications?) {
      return NotificationContent(notifications: notifications);
    }

    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple3),
    );
  }
}

class NotificationTopBar extends StatelessWidget {
  const NotificationTopBar({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kTopBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kTopBarTitleSidePadding,
            ),
            child: Text(
              '알림',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(color: AppColors.text),
            ),
          ),
          Positioned(
            left:
                _kTopBarHorizontalPadding -
                (AppDimensions.minimumTapTargetSize - _kBackIconSize) / 2,
            child: SizedBox.square(
              key: const Key('notification-back-button'),
              dimension: AppDimensions.minimumTapTargetSize,
              child: Semantics(
                button: true,
                label: '뒤로가기',
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onBackTap,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.arrowLeft,
                        width: _kBackIconSize,
                        height: _kBackIconSize,
                        colorFilter: const ColorFilter.mode(
                          AppColors.text,
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  const _NotificationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kErrorHorizontalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.gray5),
            ),
            const SizedBox(height: _kErrorMessageToRetryGap),
            Semantics(
              button: true,
              label: '알림 다시 불러오기',
              child: GestureDetector(
                onTap: onRetry,
                behavior: HitTestBehavior.opaque,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppDimensions.minimumTapTargetSize,
                    minHeight: AppDimensions.minimumTapTargetSize,
                  ),
                  child: Center(
                    child: Text(
                      '다시 시도',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                        decoration: TextDecoration.underline,
                      ),
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

class _ErrorNotificationRepository extends NotificationRepository {
  const _ErrorNotificationRepository();

  @override
  Future<List<NotificationModel>> getNotifications() {
    return Future.error(const ApiException('알림을 불러오지 못했습니다.'));
  }
}

List<NotificationModel> _previewNotifications() {
  return [
    NotificationModel(
      notificationId: 12,
      type: 'TRAVEL_JOIN',
      title: '경주 여행!!!',
      content: '여행 로그가 생성되었습니다.',
      isRead: false,
      createdAt: DateTime(2026, 7, 29, 17),
    ),
    NotificationModel(
      notificationId: 11,
      type: 'COURSE',
      title: '경주 여행!!!',
      content: '오늘의 코스를 모두 완료했습니다.',
      isRead: true,
      createdAt: DateTime(2026, 7, 29, 17),
    ),
    NotificationModel(
      notificationId: 10,
      type: 'TRAVEL_JOIN',
      title: '경주 여행!!!',
      content: '황현진님이 여행에 참가했습니다.',
      isRead: true,
      createdAt: DateTime(2026, 7, 29, 15),
    ),
    NotificationModel(
      notificationId: 9,
      type: 'COURSE',
      title: '경주 여행!!!',
      content: '지금 로그를 촬영해볼까요?',
      isRead: true,
      createdAt: DateTime(2026, 7, 29, 17),
    ),
    NotificationModel(
      notificationId: 8,
      type: 'TRAVEL',
      title: '경주 여행!!!',
      content: '내일 여행이 시작됩니다!',
      isRead: true,
      createdAt: DateTime(2026, 7, 29, 17),
    ),
  ];
}

@Preview(group: 'haerim', name: 'Notification Screen', size: Size(393, 852))
Widget notificationScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NotificationScreen(initialNotifications: _previewNotifications()),
  );
}

@Preview(
  group: 'haerim',
  name: 'Notification Screen - Error',
  size: Size(393, 852),
)
Widget notificationScreenErrorPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NotificationScreen(repository: _ErrorNotificationRepository()),
  );
}
