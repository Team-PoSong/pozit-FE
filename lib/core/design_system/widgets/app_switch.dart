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

/// 누를 때마다 켜짐/꺼짐이 부드럽게 넘어가는 걸 확인하는 데모.
class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return AppSwitch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

@Preview(group: 'haerim', name: 'AppSwitch')
Widget appSwitchPreview() => const _SwitchDemo();