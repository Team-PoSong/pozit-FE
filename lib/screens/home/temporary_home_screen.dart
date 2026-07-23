import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';

class TemporaryHomeScreen extends StatelessWidget {
  const TemporaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '로그인 성공',
              style: AppTextStyles.headline.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            Text(
              '홈 화면 연결 예정',
              style: AppTextStyles.body.copyWith(color: AppColors.gray5),
            ),
          ],
        ),
      ),
    );
  }
}
