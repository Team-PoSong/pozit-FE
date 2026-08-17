import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/button/app_button.dart';

const double _kHorizontalPadding = 24.0;
const double _kContentTopPadding = 27.0;
const int _kFeedbackMaxLength = 1000;

class FeedbackContent extends StatelessWidget {
  const FeedbackContent({
    super.key,
    required this.controller,
    required this.currentLength,
    required this.isSubmitting,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int currentLength;
  final bool isSubmitting;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final canSubmit = controller.text.trim().isNotEmpty && !isSubmitting;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _kHorizontalPadding,
              _kContentTopPadding,
              _kHorizontalPadding,
              MediaQuery.viewPaddingOf(context).bottom +
                  AppDimensions.bottomNavigationSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '의견을 남겨주세요.',
                  style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: controller,
                  hintText: 'Pozit에 전하고 싶은 내용을 입력해주세요.',
                  readOnly: isSubmitting,
                  minLines: 6,
                  maxLines: 8,
                  maxLength: _kFeedbackMaxLength,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_kFeedbackMaxLength),
                  ],
                  onChanged: onChanged,
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentLength/$_kFeedbackMaxLength',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSub,
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: '보내기',
                  isEnabled: canSubmit,
                  onPressed: onSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(group: 'haerim', name: '피드백 입력', size: Size(393, 746))
Widget feedbackContentPreview() {
  final controller = TextEditingController(text: '앱을 잘 사용하고 있어요.');
  return MaterialApp(
    home: Scaffold(
      body: FeedbackContent(
        controller: controller,
        currentLength: controller.text.length,
        isSubmitting: false,
        onChanged: (_) {},
        onSubmit: () {},
      ),
    ),
  );
}
