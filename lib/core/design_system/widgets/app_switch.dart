import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';

/// on/off 스위치
class AppSwitch extends StatefulWidget {
  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.isEnabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final bool isEnabled;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  static const _animationDuration = Duration(milliseconds: 200);
  static const double _trackWidth = 60.0;
  static const double _trackHeight = 32.0;
  static const double _thumbSize = 26.0;
  static const double _trackPadding = 3.0;

  bool _shouldAnimate = false;

  bool get _isOn => widget.value && widget.isEnabled;

  @override
  void didUpdateWidget(covariant AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOn = oldWidget.value && oldWidget.isEnabled;
    _shouldAnimate = wasOn != _isOn;
  }

  @override
  Widget build(BuildContext context) {
    final duration = _shouldAnimate ? _animationDuration : Duration.zero;
    final isInteractive = widget.isEnabled && widget.onChanged != null;
    return Semantics(
      label: widget.semanticLabel,
      toggled: _isOn,
      enabled: isInteractive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isInteractive
            ? () => widget.onChanged!.call(!widget.value)
            : null,
        child: SizedBox(
          width: _trackWidth,
          height: AppDimensions.minimumTapTargetSize,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              width: _trackWidth,
              height: _trackHeight,
              padding: const EdgeInsets.all(_trackPadding),
              decoration: BoxDecoration(
                color: _isOn ? AppColors.primary : AppColors.gray4,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: Curves.easeOut,
                alignment: _isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: SizedBox.square(dimension: _thumbSize),
                ),
              ),
            ),
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
      semanticLabel: '알림 설정',
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

@Preview(group: 'haerim', name: 'AppSwitch')
Widget appSwitchPreview() => const _SwitchDemo();
