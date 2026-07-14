import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

/// 선택 가능한 태그 칩 (예: #문화, #예술)
class AppTagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppTagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple1 : AppColors.gray2,
          borderRadius: BorderRadius.circular(9999.0),
          border: isSelected
              ? null
              : Border.all(color: AppColors.gray3, width: 0.5),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.caption2.copyWith(color: AppColors.purple3)
              : AppTextStyles.caption.copyWith(color: AppColors.gray5),
        ),
      ),
    );
  }
}

/// 삭제(x) 가능한 칩
class AppDeletableChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;

  const AppDeletableChip({super.key, required this.label, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppColors.purple1,
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: AppColors.purple3, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          GestureDetector(
            onTap: onDeleted,
            child: SvgPicture.asset(
              AppIcons.close,
              width: 16.0,
              height: 16.0,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppTagChip - 선택됨')
Widget appTagChipSelectedPreview() =>
    const AppTagChip(label: '# 문화', isSelected: true);

@Preview(group: 'haerim', name: 'AppTagChip - 선택안됨')
Widget appTagChipUnselectedPreview() => const AppTagChip(label: '# 예술');

@Preview(group: 'haerim', name: 'AppDeletableChip - 경주월드')
Widget appDeletableChipPreview() => const AppDeletableChip(label: '경주월드');
