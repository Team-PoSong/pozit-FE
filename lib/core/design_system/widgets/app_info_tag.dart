import 'package:flutter/material.dart';

import '../app_colors.dart';

const TextStyle _infoTagTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 10,
  fontWeight: FontWeight.w500,
  height: 14 / 10,
  letterSpacing: 0,
  color: AppColors.gray5,
);

/// 여행 상세 화면에서 사용하는 정보 태그입니다.
class AppInfoTag extends StatelessWidget {
  const AppInfoTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = label.startsWith('#') ? label : '# $label';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.gray5, width: 0.5),
        ),
      ),
      child: Text(text, style: _infoTagTextStyle),
    );
  }
}
