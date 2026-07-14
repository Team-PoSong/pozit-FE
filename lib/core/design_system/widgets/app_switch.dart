import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';

/// on/off 스위치
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60.0,
        height: 32.0,
        padding: value
            ? const EdgeInsets.fromLTRB(30.0, 3.0, 4.0, 3.0)
            : const EdgeInsets.fromLTRB(4.0, 3.0, 30.0, 3.0),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.gray4,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          width: 26.0,
          height: 26.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppSwitch - 켜짐')
Widget appSwitchOnPreview() => const AppSwitch(value: true);

@Preview(group: 'haerim', name: 'AppSwitch - 꺼짐')
Widget appSwitchOffPreview() => const AppSwitch(value: false);
