import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

enum AppCourseMethod { recommendation, create, wish }

class AppCourseMethodSelect extends StatefulWidget {
  const AppCourseMethodSelect({
    super.key,
    required this.method,
    this.isSelected,
    this.initiallySelected = false,
    this.onTap,
  });

  final AppCourseMethod method;
  final bool? isSelected;
  final bool initiallySelected;
  final VoidCallback? onTap;

  @override
  State<AppCourseMethodSelect> createState() => _AppCourseMethodSelectState();
}

class _AppCourseMethodSelectState extends State<AppCourseMethodSelect> {
  static const Color _backgroundColor = Color(0xFFF9F8FF);

  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? widget.initiallySelected;
  }

  @override
  void didUpdateWidget(AppCourseMethodSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != null &&
        widget.isSelected != oldWidget.isSelected) {
      _isSelected = widget.isSelected!;
    }
  }

  void _handleTap() {
    if (widget.isSelected == null && !_isSelected) {
      setState(() => _isSelected = true);
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final data = _CourseMethodData.from(widget.method);

    return Semantics(
      button: true,
      selected: _isSelected,
      label: '${data.title}, ${data.description}',
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 111,
          padding: const EdgeInsets.only(left: 25, right: 20),
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: Border.all(
              width: 1,
              color: _isSelected ? AppColors.purple2 : AppColors.purple1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset(data.icon, width: 25, height: 25),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      data.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(AppIcons.arrowRightBig, width: 25, height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseMethodData {
  const _CourseMethodData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final String icon;

  factory _CourseMethodData.from(AppCourseMethod method) {
    return switch (method) {
      AppCourseMethod.recommendation => const _CourseMethodData(
        title: '추천 받기',
        description: 'Pozit픽 코스와 다른 사람 코스를 둘러봐요',
        icon: AppIcons.user,
      ),
      AppCourseMethod.create => const _CourseMethodData(
        title: '직접 만들기',
        description: '원하는 장소를 선택해 직접 만들어요',
        icon: AppIcons.create,
      ),
      AppCourseMethod.wish => const _CourseMethodData(
        title: '찜한 코스',
        description: '내가 저장한 코스 가져오기',
        icon: AppIcons.wish,
      ),
    };
  }
}

@Preview(group: 'hycho', name: 'Course Method - 추천 받기')
Widget appCourseMethodRecommendationPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppCourseMethodSelect(method: AppCourseMethod.recommendation),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Course Method - 직접 만들기')
Widget appCourseMethodCreatePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppCourseMethodSelect(method: AppCourseMethod.create),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Course Method - 찜한 코스')
Widget appCourseMethodWishPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppCourseMethodSelect(method: AppCourseMethod.wish),
      ),
    ),
  );
}
