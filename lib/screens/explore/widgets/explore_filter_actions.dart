import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/button/app_button.dart';

class ExploreFilterActions extends StatelessWidget {
  const ExploreFilterActions({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: '옵션 초기화',
            style: AppButtonStyle.tonal,
            backgroundColor: AppColors.gray2,
            contentColor: AppColors.gray5,
            padding: const EdgeInsets.symmetric(vertical: 24),
            borderRadius: 12,
            textStyle: AppTextStyles.subTitle,
            onPressed: onReset,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            text: '적용하기',
            padding: const EdgeInsets.symmetric(vertical: 24),
            borderRadius: 12,
            textStyle: AppTextStyles.subTitle,
            onPressed: onApply,
          ),
        ),
      ],
    );
  }
}

@Preview(group: 'haerim', name: '탐색 필터 버튼')
Widget exploreFilterActionsPreview() => Padding(
  padding: const EdgeInsets.all(24),
  child: ExploreFilterActions(onReset: () {}, onApply: () {}),
);
