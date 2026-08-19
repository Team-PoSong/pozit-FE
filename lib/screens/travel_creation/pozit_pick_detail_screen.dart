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
import '../../core/design_system/widgets/app_info_tag.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/saved_travel_model.dart';
import '../../data/mock/mock_travel_courses.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/repositories/local/travel_store.dart';
import '../course_edit/course_edit_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';

/// Pozit이 추천한 강릉 코스를 확인하고 저장하는 화면입니다.
class PozitPickDetailScreen extends StatefulWidget {
  const PozitPickDetailScreen({super.key});

  @override
  State<PozitPickDetailScreen> createState() => _PozitPickDetailScreenState();
}

class _PozitPickDetailScreenState extends State<PozitPickDetailScreen> {
  int _selectedDay = 1;

  List<TravelCourseModel> get _courses => buildMockTravelCourses(
    startDate: DateTime(2026, 6, 1),
    dayCount: 4,
    spots: const [
      MockCourseSpot(
        name: '경포생태습지공원',
        address: '강원특별자치도 강릉시',
        latitude: 37.79,
        longitude: 128.90,
      ),
      MockCourseSpot(
        name: '초당순두부',
        address: '강원특별자치도 강릉시',
        latitude: 37.80,
        longitude: 128.91,
      ),
      MockCourseSpot(
        name: '강문 해변',
        address: '강원특별자치도 강릉시',
        latitude: 37.81,
        longitude: 128.92,
      ),
      MockCourseSpot(
        name: '정동진 해변',
        address: '강원특별자치도 강릉시',
        latitude: 37.82,
        longitude: 128.93,
      ),
    ],
  );

  void _handlePrimaryTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseEditScreen(
          courses: _courses,
          initialDay: _selectedDay,
          isCreationFlow: true,
          onSave: (spotsByDay) {
            final savedCourses = _courses
                .map(
                  (course) => TravelCourseModel(
                    courseId: course.courseId,
                    dayNumber: course.dayNumber,
                    date: course.date,
                    spots: spotsByDay[course.dayNumber] ?? course.spots,
                  ),
                )
                .toList();
            TravelStore.instance.save(
              SavedTravelModel(
                id: 'pozit-pick-gangneung',
                title: '6월 추천, 강릉은 어때요?',
                location: '강원 강릉',
                dateText: '1박 2일',
                author: '나',
                info: TravelInfoCardModel(
                  destination: '강릉',
                  startDate: DateTime(2026, 6, 1),
                  endDate: DateTime(2026, 6, 2),
                  companionCount: 1,
                  tags: const ['기록', '미식'],
                  visitedPlaceCount: 0,
                  recordCount: 0,
                  completionRate: 0,
                ),
                courses: savedCourses,
                dDay: 'D-30',
                backgroundImage: const AssetImage(AppImages.travelMockup),
                tags: const ['기록', '미식'],
                participantCount: 1,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = _courses[_selectedDay - 1];
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Hero(onBack: () => Navigator.of(context).maybePop()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.paddingOf(context).bottom +
                  AppDimensions.screenBottomPadding,
            ),
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
                  const SizedBox(height: 16),
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
                    AppInfoTag(label: '# 기록'),
                    const SizedBox(width: 4),
                    AppInfoTag(label: '# 미식'),
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
