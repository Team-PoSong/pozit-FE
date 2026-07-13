import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '직접 입력',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(4));

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        maxLines: 1,
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
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSub,
            height: 20 / 14,
            letterSpacing: -0.5,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 28),
          border: const OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(width: 1, color: AppColors.purple2),
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
        child: AppInputField(controller: controller, autofocus: true),
      ),
    ),
  );
}
