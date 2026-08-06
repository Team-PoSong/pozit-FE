import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/travel_course_model.dart';
import '../course_edit/course_edit_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';

class PozitPickDetailScreen extends StatefulWidget {
  const PozitPickDetailScreen({super.key});

  @override
  State<PozitPickDetailScreen> createState() => _PozitPickDetailScreenState();
}

class _PozitPickDetailScreenState extends State<PozitPickDetailScreen> {
  int _selectedDay = 1;

  static const _spotNames = ['경포생태습지공원', '초당순두부', '강문 해변', '정동진 해변'];

  List<TravelCourseModel> get _courses => List.generate(
    4,
    (index) => TravelCourseModel(
      courseId: index + 1,
      dayNumber: index + 1,
      date: DateTime(2026, 6, index + 1),
      spots: [
        CourseSpotModel(
          courseSpotId: index + 1,
          touristSpotId: index + 1,
          name: _spotNames[index],
          address: '강원특별자치도 강릉시',
          latitude: 37.79 + index * 0.01,
          longitude: 128.90 + index * 0.01,
          orderIndex: 0,
          status: 'notVisited',
        ),
      ],
    ),
  );

  void _handlePrimaryTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CourseEditScreen(courses: _courses, initialDay: _selectedDay),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = _courses[_selectedDay - 1];
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(onBack: () => Navigator.of(context).maybePop()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 180),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      AppDateDetailSelect(
                        dayCount: 4,
                        selectedDay: _selectedDay,
                        onChanged: (day) => setState(() => _selectedDay = day),
                      ),
                      const SizedBox(height: 10),
                      _CourseCard(
                        course: course,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TravelCourseMapScreen(
                              courses: _courses,
                              status: AppTravelStatus.completed,
                              totalDays: _courses.length,
                              initialDay: _selectedDay,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        AppImages.carrier,
                        width: 94,
                        height: 154,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom:
                MediaQuery.paddingOf(context).bottom +
                AppDimensions.screenBottomPadding,
            child: Column(
              children: [
                Text(
                  'Pozit이 직접 준비한 코스와 떠나볼까요?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.gray5),
                ),
                const SizedBox(height: 26),
                AppButton(text: '이 코스 따라하기', onPressed: _handlePrimaryTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImages.travelMockup, fit: BoxFit.cover),
          ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
          Positioned(
            left: 14,
            top: MediaQuery.paddingOf(context).top + 14,
            child: GestureDetector(
              onTap: onBack,
              child: SvgPicture.asset(
                AppIcons.arrowLeftWhite,
                width: 24,
                height: 24,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가족과 함께, 강릉은 어때요?',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '강릉',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '6월 추천 · 1박 2일',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Tag(label: '# 기록'),
                    const SizedBox(width: 4),
                    _Tag(label: '# 미식'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: AppColors.gray5, width: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w500,
          color: AppColors.gray5,
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});
  final TravelCourseModel course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppMapCard(
      title: course.firstSpotName,
      markers: [
        for (final spot in course.spots)
          MapMarker(
            position: LatLng(spot.latitude, spot.longitude),
            label: spot.name,
          ),
      ],
      currentPage: course.dayNumber - 1,
      pageCount: 4,
      onCourseTap: onTap,
    );
  }
}
