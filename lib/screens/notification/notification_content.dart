import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../data/models/notification/notification_model.dart';
import 'notification_list_item.dart';

const double _kHorizontalPadding = 24.0;
const double _kListTopPadding = 9.0;
const double _kListBottomPadding = 24.0;
const double _kItemGap = 8.0;

class NotificationContent extends StatelessWidget {
  const NotificationContent({super.key, required this.notifications, this.now});

  final List<NotificationModel> notifications;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          '새로운 알림이 없습니다.',
          style: AppTextStyles.body.copyWith(color: AppColors.gray5),
        ),
      );
    }

    final currentTime = now ?? DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _kHorizontalPadding,
        _kListTopPadding,
        _kHorizontalPadding,
        _kListBottomPadding,
      ),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: _kItemGap),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationListItem(
          title: notification.title,
          body: notification.content,
          time: formatNotificationTime(
            notification.createdAt,
            now: currentTime,
          ),
        );
      },
    );
  }
}

String formatNotificationTime(DateTime createdAt, {required DateTime now}) {
  final difference = now.difference(createdAt);

  if (difference.isNegative || difference.inMinutes < 1) {
    return '방금 전';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}분 전';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}시간 전';
  }
  return '${difference.inDays}일 전';
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
  ];
}

@Preview(group: 'haerim', name: 'Notification Content', size: Size(393, 700))
Widget notificationContentPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.gray2,
      body: NotificationContent(
        notifications: _previewNotifications(),
        now: DateTime(2026, 7, 30, 9),
      ),
    ),
  );
}

@Preview(
  group: 'haerim',
  name: 'Notification Content - Empty',
  size: Size(393, 700),
)
Widget notificationContentEmptyPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.gray2,
      body: NotificationContent(notifications: []),
    ),
  );
}
