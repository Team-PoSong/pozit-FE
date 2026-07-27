import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

/// 여행 탐색 조건을 선택하거나 초기화하는 필터 칩입니다.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required String label,
    this.onTap,
    this.assetPackage,
  }) : _label = label,
       _iconAsset = AppIcons.arrowDown,
       _iconSize = 24;

  const AppFilterChip.icon({
    super.key,
    required String iconAsset,
    this.onTap,
    this.assetPackage,
  }) : _label = null,
       _iconAsset = iconAsset,
       _iconSize = 15;

  final String? _label;
  final String _iconAsset;
  final double _iconSize;
  final VoidCallback? onTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    final label = _label;
    final isInteractive = onTap != null;

    return Semantics(
      button: isInteractive,
      enabled: isInteractive,
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray5),
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
