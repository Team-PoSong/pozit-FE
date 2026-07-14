import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';

class NotificationListItem extends StatelessWidget {
  final String title;
  final String body;
  final String time;

  const NotificationListItem({
    super.key,
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 347.0,
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 19.0,
        bottom: 20.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gray2, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subTitle.copyWith(color: AppColors.purple3),
          ),
          const SizedBox(height: 15.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(color: AppColors.gray5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'NotificationListItem')
Widget notificationListItemPreview() => const NotificationListItem(
  title: '경주 여행!!!',
  body: '오늘의 코스를 모두 완료했습니다.',
  time: '16시간 전',
);

@Preview(group: 'haerim', name: 'NotificationListItem - 2 lines')
Widget notificationListItemTwoLinesPreview() => const NotificationListItem(
  title: '경주 여행!!!',
  body: '오늘의 코스를 모두 완료했습니다. 알림이 길어지면 두우우우우줄로 됩니드아아아아.',
  time: '16시간 전',
);
