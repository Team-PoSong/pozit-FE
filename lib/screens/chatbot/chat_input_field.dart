import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';

class AppChatInputField extends StatefulWidget {
  final String initialText;
  final String hintText;
  final ValueChanged<String>? onSubmitted;

  const AppChatInputField({
    super.key,
    this.initialText = '',
    this.hintText = '포짓 AI에게 물어보세요.',
    this.onSubmitted,
  });

  @override
  State<AppChatInputField> createState() => _AppChatInputFieldState();
}

class _AppChatInputFieldState extends State<AppChatInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant AppChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 299.0,
      height: 49.0,
      padding: const EdgeInsets.only(left: 26.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: AppColors.gray5, width: 0.5),
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSubmitted,
        style: AppTextStyles.body.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.gray5),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppChatInputField - 빈 상태')
Widget appChatInputFieldEmptyPreview() => const AppChatInputField();

@Preview(group: 'haerim', name: 'AppChatInputField - 입력됨')
Widget appChatInputFieldFilledPreview() =>
    const AppChatInputField(initialText: '2일차가 너무 빡빡해.');