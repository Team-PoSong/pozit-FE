import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// 지역 선택 토글 (예: 전국/서울)
class AppRegionToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppRegionToggle({
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
        width: 80.0,
        height: 39.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.purple1,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: AppTextStyles.subTitle.copyWith(
            color: isSelected ? AppColors.white : AppColors.purple2,
          ),
        ),
      ),
    );
  }
}

/// 공개/비공개 선택 토글
class AppVisibilityToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppVisibilityToggle({
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
        width: 166.0,
        height: 51.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple1 : AppColors.gray2,
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.0)
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.subTitle.copyWith(
            color: isSelected ? AppColors.primary : AppColors.gray5,
          ),
        ),
      ),
    );
  }
}

/// 눌러서 선택/비선택이 바뀌는 걸 확인하는 지역 토글 데모
class _RegionToggleDemo extends StatefulWidget {
  final String label;
  final bool initialSelected;

  const _RegionToggleDemo({required this.label, required this.initialSelected});

  @override
  State<_RegionToggleDemo> createState() => _RegionToggleDemoState();
}

class _RegionToggleDemoState extends State<_RegionToggleDemo> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return AppRegionToggle(
      label: widget.label,
      isSelected: _selected,
      onTap: () => setState(() => _selected = !_selected),
    );
  }
}

/// 눌러서 선택/비선택이 바뀌는 걸 확인하는 공개/비공개 토글 데모
class _VisibilityToggleDemo extends StatefulWidget {
  final String label;
  final bool initialSelected;

  const _VisibilityToggleDemo({required this.label, required this.initialSelected});

  @override
  State<_VisibilityToggleDemo> createState() => _VisibilityToggleDemoState();
}

class _VisibilityToggleDemoState extends State<_VisibilityToggleDemo> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return AppVisibilityToggle(
      label: widget.label,
      isSelected: _selected,
      onTap: () => setState(() => _selected = !_selected),
    );
  }
}

@Preview(group: 'haerim', name: 'AppRegionToggle - 전국(선택)')
Widget appRegionToggleSelectedPreview() =>
    const _RegionToggleDemo(label: '전국', initialSelected: true);

@Preview(group: 'haerim', name: 'AppRegionToggle - 서울(비선택)')
Widget appRegionToggleUnselectedPreview() =>
    const _RegionToggleDemo(label: '서울', initialSelected: false);

@Preview(group: 'haerim', name: 'AppVisibilityToggle - 비공개(선택)')
Widget appVisibilityToggleSelectedPreview() =>
    const _VisibilityToggleDemo(label: '비공개', initialSelected: true);

@Preview(group: 'haerim', name: 'AppVisibilityToggle - 공개(비선택)')
Widget appVisibilityToggleUnselectedPreview() =>
    const _VisibilityToggleDemo(label: '공개', initialSelected: false);