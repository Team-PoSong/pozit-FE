import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/button/app_chatbot_button.dart';
import '../../core/design_system/widgets/button/app_circle_button.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_creation_data.dart';

class TravelCourseCreationScreen extends StatefulWidget {
  const TravelCourseCreationScreen({
    super.key,
    required this.travelInfo,
    this.courseCounts = const {},
    this.onAiTap,
    this.onAddCourseTap,
    this.onStartTravel,
    this.onBackTap,
  });

  final TravelInfoResult travelInfo;
  final Map<int, int> courseCounts;
  final VoidCallback? onAiTap;
  final ValueChanged<int>? onAddCourseTap;
  final VoidCallback? onStartTravel;
  final VoidCallback? onBackTap;

  @override
  State<TravelCourseCreationScreen> createState() =>
      _TravelCourseCreationScreenState();
}

class _TravelCourseCreationScreenState
    extends State<TravelCourseCreationScreen> {
  int _selectedDay = 1;

  int get _dayCount =>
      widget.travelInfo.dateRange.duration.inDays.clamp(0, 3) + 1;

  bool get _hasAnyCourse =>
      widget.courseCounts.values.any((count) => count > 0);

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayCourseCount = widget.courseCounts[_selectedDay] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
                Positioned(
                  right: 24,
                  top: 14.5,
                  child: AppChatbotButton(onPressed: widget.onAiTap),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 2),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppDateDetailSelect(
                dayCount: _dayCount,
                selectedDay: _selectedDay,
                onChanged: (day) => setState(() => _selectedDay = day),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$_selectedDay일차',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: selectedDayCourseCount == 0
                  ? const _EmptyCourseState()
                  : Center(
                      child: Text(
                        '코스 $selectedDayCourseCount개',
                        style: AppTextStyles.subTitle.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: AppCircleButton(
                  size: 62,
                  backgroundColor: AppColors.purple3,
                  iconAsset: AppIcons.plus,
                  onPressed: () => widget.onAddCourseTap?.call(_selectedDay),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '여행 시작하기',
                isEnabled: _hasAnyCourse,
                onPressed: widget.onStartTravel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourseState extends StatelessWidget {
  const _EmptyCourseState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.posongPlain,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            '코스를 만들어볼까요?',
            style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Course Creation', size: Size(393, 852))
Widget travelCourseCreationScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelCourseCreationScreen(
        travelInfo: TravelInfoResult(
          destination: '경상북도 경주시',
          dateRange: DateTimeRange(
            start: DateTime(2026, 7, 3),
            end: DateTime(2026, 7, 6),
          ),
          name: '포송한 여행',
          tags: const {'미식', '문화'},
        ),
      ),
    ),
  );
}
