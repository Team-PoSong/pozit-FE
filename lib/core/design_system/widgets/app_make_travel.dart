import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

enum AppMakeTravelType { create, joinWithInviteCode }

class AppMakeTravel extends StatefulWidget {
  const AppMakeTravel({
    super.key,
    required this.type,
    this.isSelected,
    this.initiallySelected = false,
    this.onPressed,
  });

  final AppMakeTravelType type;
  final bool? isSelected;
  final bool initiallySelected;
  final VoidCallback? onPressed;

  @override
  State<AppMakeTravel> createState() => _AppMakeTravelState();
}

class _AppMakeTravelState extends State<AppMakeTravel> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? widget.initiallySelected;
  }

  @override
  void didUpdateWidget(AppMakeTravel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != null &&
        widget.isSelected != oldWidget.isSelected) {
      _isSelected = widget.isSelected!;
    }
  }

  void _handleTap() {
    if (widget.isSelected == null && !_isSelected) {
      setState(() => _isSelected = true);
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (widget.type) {
      AppMakeTravelType.create => '여행 만들기',
      AppMakeTravelType.joinWithInviteCode => '초대코드로 참여하기',
    };

    return Semantics(
      button: true,
      selected: _isSelected,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 189,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isSelected ? AppColors.primary : AppColors.gray2,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: _isSelected ? AppColors.white : AppColors.gray5,
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Make Travel - 여행 만들기 기본')
Widget appMakeTravelCreateDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(body: AppMakeTravel(type: AppMakeTravelType.create)),
  );
}

@Preview(group: 'hycho', name: 'Make Travel - 여행 만들기 선택')
Widget appMakeTravelCreateSelectedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: AppMakeTravel(
        type: AppMakeTravelType.create,
        initiallySelected: true,
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Make Travel - 초대코드 기본')
Widget appMakeTravelJoinDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: AppMakeTravel(type: AppMakeTravelType.joinWithInviteCode),
    ),
  );
}

@Preview(group: 'hycho', name: 'Make Travel - 초대코드 선택')
Widget appMakeTravelJoinSelectedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: AppMakeTravel(
        type: AppMakeTravelType.joinWithInviteCode,
        initiallySelected: true,
      ),
    ),
  );
}
