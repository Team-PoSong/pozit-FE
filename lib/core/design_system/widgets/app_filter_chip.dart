import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required String label,
    this.onTap,
    this.assetPackage,
    this.isSelected = false,
  }) : _label = label,
       _iconAsset = AppIcons.arrowDown,
       _iconSize = 24;

  const AppFilterChip.icon({
    super.key,
    required String iconAsset,
    this.onTap,
    this.assetPackage,
    this.isSelected = false,
  }) : _label = null,
       _iconAsset = iconAsset,
       _iconSize = 15;

  final String? _label;
  final String _iconAsset;
  final double _iconSize;
  final VoidCallback? onTap;
  final String? assetPackage;

  /// 필터 적용 상태는 글씨 색상만 변경해 표시합니다.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final label = _label;
    final isInteractive = onTap != null;

    return Semantics(
      button: isInteractive,
      enabled: isInteractive,
      selected: isSelected,
      label: label ?? '필터 초기화',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            border: Border.all(color: AppColors.gray3, width: 0.5),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label != null) ...[
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.purple3 : AppColors.gray5,
                  ),
                ),
                const SizedBox(width: 1),
              ],
              SvgPicture.asset(
                _iconAsset,
                package: assetPackage,
                width: _iconSize,
                height: _iconSize,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Filter Chip')
Widget appFilterChipPreview() {
  return const Material(
    color: AppColors.white,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFilterChip(label: '지역', assetPackage: 'pozit'),
          SizedBox(width: 8),
          AppFilterChip.icon(
            iconAsset: AppIcons.turnBack,
            assetPackage: 'pozit',
          ),
        ],
      ),
    ),
  );
}
