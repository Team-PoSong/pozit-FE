import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';

const TextStyle _badgeTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

/// 공개/비공개 상태표시 뱃지
class AppVisibilityBadge extends StatelessWidget {
  final String label;

  const AppVisibilityBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 67.0,
      height: 26.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.purple1,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.primary, width: 0.5),
      ),
      child: Text(
        label,
        style: _badgeTextStyle.copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// 알약 모양 상태 뱃지 (예: 진행중, D-24)
/// isFilled: true - primary 배경+흰 글씨, false - 흰 배경+primary 글씨
class AppPillBadge extends StatelessWidget {
  final String label;
  final bool isFilled;

  const AppPillBadge({super.key, required this.label, this.isFilled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 67.0,
      height: 26.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        label,
        style: _badgeTextStyle.copyWith(
          color: isFilled ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppVisibilityBadge - 공개')
Widget appVisibilityBadgePublicPreview() =>
    const AppVisibilityBadge(label: '공개');

@Preview(group: 'haerim', name: 'AppVisibilityBadge - 비공개')
Widget appVisibilityBadgePrivatePreview() =>
    const AppVisibilityBadge(label: '비공개');

@Preview(group: 'haerim', name: 'AppPillBadge - 진행중')
Widget appPillBadgeInProgressPreview() => const AppPillBadge(label: '진행중');

@Preview(group: 'haerim', name: 'AppPillBadge - D-24')
Widget appPillBadgeDdayPreview() =>
    const AppPillBadge(label: 'D-24', isFilled: false);
