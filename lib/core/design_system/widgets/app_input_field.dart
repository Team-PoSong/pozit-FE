import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppInputField extends StatefulWidget {
  const AppInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '직접 입력',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.isError = false,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final bool isError;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  late bool _ownsController;
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(AppInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController(widget.controller);
    }
  }

  void _attachController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _handleTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(4));
    final borderSide = widget.isError
        ? const BorderSide(width: 1, color: AppColors.error)
        : _hasText
        ? const BorderSide(width: 1, color: AppColors.purple3)
        : BorderSide.none;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        maxLines: 1,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) => null,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.text,
          height: 20 / 14,
          letterSpacing: -0.5,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.gray2,
          hintText: widget.hintText,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSub,
            height: 20 / 14,
            letterSpacing: -0.5,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Input Field - 기본형')
Widget appInputFieldDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(padding: EdgeInsets.all(20), child: AppInputField()),
    ),
  );
}

@Preview(group: 'hycho', name: 'Input Field - 입력값 있음')
Widget appInputFieldValuePreview() {
  final controller = TextEditingController(text: '윤지');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppInputField(controller: controller),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Input Field - 에러')
Widget appInputFieldErrorPreview() {
  final controller = TextEditingController(text: '참새@!#1');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppInputField(controller: controller, isError: true),
      ),
    ),
  );
}
