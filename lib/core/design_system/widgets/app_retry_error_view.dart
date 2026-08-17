import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

class AppRetryErrorView extends StatelessWidget {
  const AppRetryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.retrySemanticLabel,
    this.retryLabel = '다시 시도',
  });

  final String message;
  final VoidCallback onRetry;
  final String retrySemanticLabel;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.gray5),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: retrySemanticLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppDimensions.minimumTapTargetSize,
                  minHeight: AppDimensions.minimumTapTargetSize,
                ),
                child: Center(
                  child: Text(
                    retryLabel,
                    style: AppTextStyles.body.copyWith(color: AppColors.text),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: '재시도 에러', size: Size(393, 852))
Widget appRetryErrorViewPreview() => MaterialApp(
  home: Scaffold(
    body: AppRetryErrorView(
      message: '정보를 불러오지 못했습니다.',
      retrySemanticLabel: '정보 다시 불러오기',
      onRetry: () {},
    ),
  ),
);
