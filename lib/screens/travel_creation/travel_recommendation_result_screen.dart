import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
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
                      dateText: '7/2 ~ 7/3 · 1박 2일',
                      tags: const ['문화', '탐험'],
                      author: '포송',
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: onRecommendationTap,
                    ),
                    const SizedBox(height: 8),
                    const AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '경주 여행',
                      location: '경북 경주',
                      dateText: '7/2 ~ 7/3 · 1박 2일',
                      tags: ['힐링', '미식'],
                      author: '해림',
                      participantCount: 2,
                      favoriteCount: 14,
                      backgroundImage: AssetImage(AppImages.travelMockup),
                    ),
                    const SizedBox(height: 8),
                    const AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '강릉 데이트',
                      location: '강원 강릉',
                      dateText: '7/2 ~ 7/3 · 1박 2일',
                      tags: ['문화', '탐험'],
                      author: '민서',
                      participantCount: 2,
                      favoriteCount: 12,
                      backgroundImage: AssetImage(AppImages.travelMockup),
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
