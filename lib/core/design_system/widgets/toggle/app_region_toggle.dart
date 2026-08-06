import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 9.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.purple1,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.subTitle.copyWith(
              color: isSelected ? AppColors.white : AppColors.purple2,
            ),
          ),
        ),
      ),
    );
  }
}

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

@Preview(group: 'haerim', name: 'AppRegionToggle - 전국(선택)')
Widget appRegionToggleSelectedPreview() =>
    const _RegionToggleDemo(label: '전국', initialSelected: true);

@Preview(group: 'haerim', name: 'AppRegionToggle - 서울(비선택)')
Widget appRegionToggleUnselectedPreview() =>
    const _RegionToggleDemo(label: '서울', initialSelected: false);
