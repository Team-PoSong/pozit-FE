import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSearchTap,
    this.readOnly = false,
    this.hintText = '찾고 싶은 여행을 검색해주세요.',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSearchTap;
  final bool readOnly;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.only(left: 28, right: 20),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              readOnly: readOnly,
              maxLines: 1,
              cursorColor: AppColors.text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                height: 20 / 14,
                letterSpacing: -0.5,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.gray5,
                  height: 20 / 14,
                  letterSpacing: -0.5,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            behavior: HitTestBehavior.opaque,
            child: SvgPicture.asset(AppIcons.search, width: 24, height: 24),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Search Bar - 기본형')
Widget appSearchBarDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(padding: EdgeInsets.all(20), child: AppSearchBar()),
    ),
  );
}

@Preview(group: 'hycho', name: 'Search Bar - 검색값 있음')
Widget appSearchBarValuePreview() {
  final controller = TextEditingController(text: '경주');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppSearchBar(controller: controller),
      ),
    ),
  );
}
