import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_course_method_select.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_destination_screen.dart';

class TravelCreationScreen extends StatelessWidget {
  const TravelCreationScreen({
    super.key,
    this.onRecommendationTap,
    this.onCreateTap,
    this.onWishTap,
  });

  final VoidCallback? onRecommendationTap;
  final VoidCallback? onCreateTap;
  final VoidCallback? onWishTap;

  void _openDestinationSearch(BuildContext context, VoidCallback? callback) {
    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TravelDestinationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TravelDetailTopBar(
              title: '여행 생성하기',
              onBackTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '어떻게 코스를 만들까요?',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '원하는 방식으로 쉽고 빠르게 \n나만의 여행코스를 만들어보세요.',
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                    ),
                    const SizedBox(height: 25),
                    AppCourseMethodSelect(
                      method: AppCourseMethod.recommendation,
                      onTap: () =>
                          _openDestinationSearch(context, onRecommendationTap),
                    ),
                    const SizedBox(height: 12),
                    AppCourseMethodSelect(
                      method: AppCourseMethod.create,
                      onTap: () => _openDestinationSearch(context, onCreateTap),
                    ),
                    const SizedBox(height: 12),
                    AppCourseMethodSelect(
                      method: AppCourseMethod.wish,
                      onTap: onWishTap,
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

@Preview(group: 'hycho', name: 'Travel Creation', size: Size(393, 852))
Widget travelCreationScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelCreationScreen(),
    ),
  );
}
