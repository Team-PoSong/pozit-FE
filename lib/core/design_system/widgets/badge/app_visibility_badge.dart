import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

class AppVisibilityBadge extends StatelessWidget {
  final String label;

  const AppVisibilityBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 67.0),
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.purple1,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.primary, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption2.copyWith(color: AppColors.primary),
          ),
        ],
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