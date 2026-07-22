import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

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
        constraints: const BoxConstraints(minWidth: 166.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple1 : AppColors.gray2,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.subTitle.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

@Preview(group: 'haerim', name: 'AppVisibilityToggle - 비공개(선택)')
Widget appVisibilityToggleSelectedPreview() =>
    const _VisibilityToggleDemo(label: '비공개', initialSelected: true);

@Preview(group: 'haerim', name: 'AppVisibilityToggle - 공개(비선택)')
Widget appVisibilityToggleUnselectedPreview() =>
    const _VisibilityToggleDemo(label: '공개', initialSelected: false);