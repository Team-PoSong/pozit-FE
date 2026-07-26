import 'package:flutter/material.dart';

import '../../core/design_system/app_icons.dart';
import '../../core/design_system/widgets/app_filter_chip.dart';
import '../../core/design_system/widgets/app_search_bar.dart';

/// 공통 화면 shell 안에서 표시하는 여행 탐색 본문입니다.
class ExploreContent extends StatelessWidget {
  const ExploreContent({
    super.key,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.onRegionFilterTap,
    this.onDateFilterTap,
    this.onCategoryFilterTap,
    this.onFilterResetTap,
    this.assetPackage,
  });

  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onRegionFilterTap;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onCategoryFilterTap;
  final VoidCallback? onFilterResetTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSearchBar(
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
            onSearchTap: onSearchTap,
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              AppFilterChip(
                label: '지역',
                onTap: onRegionFilterTap,
                assetPackage: assetPackage,
              ),
              const SizedBox(width: 8),
              AppFilterChip(
                label: '날짜',
                onTap: onDateFilterTap,
                assetPackage: assetPackage,
              ),
              const SizedBox(width: 8),
              AppFilterChip(
                label: '카테고리',
                onTap: onCategoryFilterTap,
                assetPackage: assetPackage,
              ),
              const SizedBox(width: 8),
              AppFilterChip.icon(
                iconAsset: AppIcons.turnBack,
                onTap: onFilterResetTap,
                assetPackage: assetPackage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
