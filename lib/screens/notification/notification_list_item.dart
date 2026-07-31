import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';

const double _kLeftContentPadding = 31.0;
const double _kRightContentPadding = 15.0;
const double _kTopContentPadding = 19.0;
const double _kBottomContentPadding = 20.0;
const double _kBorderRadius = 8.0;
const double _kTitleToBodyGap = 15.0;
const double _kBodyToTimeGap = 8.0;
const double _kTimeBottomPadding = 5.0;

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        _kLeftContentPadding,
        _kTopContentPadding,
        _kRightContentPadding,
        _kBottomContentPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subTitle.copyWith(color: AppColors.purple3),
          ),
          const SizedBox(height: _kTitleToBodyGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  body,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(width: _kBodyToTimeGap),
              Padding(
                padding: const EdgeInsets.only(bottom: _kTimeBottomPadding),
                child: Text(
                  time,
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'Notification List Item')
Widget notificationListItemPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.gray2,
      body: Padding(
        padding: EdgeInsets.all(24),
        child: NotificationListItem(
          title: '경주 여행!!!',
          body: '오늘의 코스를 모두 완료했습니다.',
          time: '16시간 전',
        ),
      ),
    ),
  );
}