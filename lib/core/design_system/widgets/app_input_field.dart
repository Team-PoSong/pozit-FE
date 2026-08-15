import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
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
    this.textColor,
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

  final Color? textColor;

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    _attachFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(AppInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController(widget.controller);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode(widget.focusNode);
    }
  }

  void _attachController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
  }

  void _detachController() {
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _attachFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode();
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChanged() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _detachController();
    _detachFocusNode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(4));
    final borderSide = widget.isError
        ? const BorderSide(width: 1, color: AppColors.error)
        : _hasFocus
        ? const BorderSide(width: 1, color: AppColors.purple3)
        : BorderSide.none;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.inputMinHeight,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onTapOutside: (_) => _focusNode.unfocus(),
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
          color: widget.textColor ?? AppColors.text,
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
