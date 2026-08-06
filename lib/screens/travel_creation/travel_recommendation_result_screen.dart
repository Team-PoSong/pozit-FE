import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../../data/models/travel_course_model.dart';
import '../../data/models/travel_info_card_model.dart';
import '../course_edit/course_edit_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import '../travel_detail/travel_detail_screen.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_creation_data.dart';

class TravelRecommendationResultScreen extends StatelessWidget {
  const TravelRecommendationResultScreen({
    super.key,
    required this.travelInfo,
    this.onBackTap,
    this.onBrowseOtherCourses,
    this.onRecommendationTap,
  });

  final TravelInfoResult travelInfo;
  final VoidCallback? onBackTap;
  final VoidCallback? onBrowseOtherCourses;
  final VoidCallback? onRecommendationTap;

  void _handleBack(BuildContext context) {
    onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  void _openPozitPick(BuildContext context) {
    onRecommendationTap?.call();
    _openTravelDetail(
      context,
      destination: '강릉',
      tags: const ['기록', '미식'],
      authorName: 'Pozit',
    );
  }

  void _openTravelDetail(
    BuildContext context, {
    required String destination,
    required List<String> tags,
    required String authorName,
  }) {
    final courses = _mockCourses(destination);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelDetailScreen(
          info: TravelInfoCardModel(
            destination: destination,
            startDate: DateTime(2026, 7, 2),
            endDate: DateTime(2026, 7, 3),
            companionCount: 2,
            tags: tags,
            visitedPlaceCount: 12,
            recordCount: 48,
            completionRate: 0.67,
          ),
          status: AppTravelStatus.completed,
          isLeader: false,
          isMyTravel: false,
          authorName: authorName,
          courses: courses,
          onCourseTap: (_) => _openCourseMap(context, courses),
          onFollowCourseTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CourseEditScreen(courses: courses),
            ),
          ),
        ),
      ),
    );
  }

  void _openCourseMap(BuildContext context, List<TravelCourseModel> courses) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelCourseMapScreen(
          courses: courses,
          status: AppTravelStatus.completed,
          totalDays: courses.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelDetailTopBar(
              title: '여행 생성하기',
              onBackTap: () => _handleBack(context),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 1),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신의 여행 취향을 담아\nPozit이 추천 코스를 준비했어요.',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        height: 1.5,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTravelCard(
                      type: AppTravelCardType.pozitPick,
                      title: '6월 추천, 강릉은 어때요?',
                      location: '강원 강릉',
                      dateText: '1박 2일',
                      tags: const ['문화', '탐험'],
                      author: '포송',
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openPozitPick(context),
                    ),
                    const SizedBox(height: 8),
                    AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '경주 여행',
                      location: '경북 경주',
                      dateText: '7/2 ~ 7/3',
                      tags: const ['힐링', '미식'],
                      author: '해림',
                      participantCount: 2,
                      favoriteCount: 14,
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openTravelDetail(
                        context,
                        destination: '경주',
                        tags: const ['힐링', '미식'],
                        authorName: '해림',
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '강릉 데이트',
                      location: '강원 강릉',
                      dateText: '7/2 ~ 7/3',
                      tags: const ['문화', '탐험'],
                      author: '민서',
                      participantCount: 2,
                      favoriteCount: 12,
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openTravelDetail(
                        context,
                        destination: '강릉',
                        tags: const ['문화', '탐험'],
                        authorName: '민서',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onBrowseOtherCourses,
                        child: Text(
                          '다른 사람 코스 둘러보기',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray5,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.gray5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<TravelCourseModel> _mockCourses(String destination) {
  final names = destination == '경주'
      ? const ['불국사', '동궁과 월지', '첨성대', '대릉원']
      : const ['경포생태습지공원', '초당순두부', '강문 해변', '정동진 해변'];

  return List.generate(
    2,
    (dayIndex) => TravelCourseModel(
      courseId: dayIndex + 1,
      dayNumber: dayIndex + 1,
      date: DateTime(2026, 7, dayIndex + 2),
      spots: List.generate(
        2,
        (spotIndex) => CourseSpotModel(
          courseSpotId: dayIndex * 2 + spotIndex + 1,
          touristSpotId: dayIndex * 2 + spotIndex + 1,
          name: names[dayIndex * 2 + spotIndex],
          address: destination == '경주' ? '경북 경주시' : '강원특별자치도 강릉시',
          latitude: 35.8 + dayIndex * 0.01 + spotIndex * 0.005,
          longitude: 129.2 + dayIndex * 0.01 + spotIndex * 0.005,
          orderIndex: spotIndex,
          status: spotIndex == 0 ? 'visited' : 'notVisited',
        ),
      ),
    ),
  );
}
