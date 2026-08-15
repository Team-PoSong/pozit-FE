import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

class AppPillBadge extends StatelessWidget {
  final String label;
  final bool isFilled;

  const AppPillBadge({super.key, required this.label, this.isFilled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 67.0),
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 6.0),
      decoration: ShapeDecoration(
        color: isFilled ? AppColors.primary : AppColors.white,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption2.copyWith(
              color: isFilled ? AppColors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppPillBadge - 진행중')
Widget appPillBadgeInProgressPreview() => const AppPillBadge(label: '진행중');

@Preview(group: 'haerim', name: 'AppPillBadge - D-24')
Widget appPillBadgeDdayPreview() =>
    const AppPillBadge(label: 'D-24', isFilled: false);