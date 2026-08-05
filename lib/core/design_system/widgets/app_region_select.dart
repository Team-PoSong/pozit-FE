import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppRegionSelect extends StatelessWidget {
  const AppRegionSelect({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onChanged,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged?.call(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 77,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 29.5, right: 24),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            border: Border.all(
              width: 0.5,
              color: isSelected ? AppColors.purple2 : AppColors.gray3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Region Select - Default')
Widget appRegionSelectDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: AppRegionSelect(label: '경상남도 경주시'),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Region Select - Selected')
Widget appRegionSelectSelectedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: AppRegionSelect(label: '경상북도 경주시', isSelected: true),
      ),
    ),
  );
}
