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
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../travel_course_map/travel_course_map_screen.dart';

/// Pozit이 추천한 강릉 코스를 확인하고 저장하는 화면입니다.
class PozitPickDetailScreen extends StatefulWidget {
  const PozitPickDetailScreen({
    super.key,
    required this.courses,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.title,
    required this.tags,
    this.backgroundImage,
    required this.onFollowCourseTap,
  });

  final List<TravelCourseModel> courses;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final String title;
  final List<String> tags;
  final ImageProvider<Object>? backgroundImage;
  final Future<void> Function() onFollowCourseTap;

  @override
  State<PozitPickDetailScreen> createState() => _PozitPickDetailScreenState();
}

class _PozitPickDetailScreenState extends State<PozitPickDetailScreen> {
  int _selectedDay = 1;
  bool _isSaving = false;

  DateTime get _startDate => widget.startDate;
  DateTime get _endDate => widget.endDate;

  int get _dayCount => _endDate.difference(_startDate).inDays + 1;

  String get _durationText => '${_dayCount - 1}박 $_dayCount일';

  List<TravelCourseModel> get _courses => widget.courses;

  Future<void> _handlePrimaryTap() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.onFollowCourseTap();
    } catch (error) {
      if (!mounted) return;
      showAppToast(
        context,
        error is ApiException
            ? error.message
            : '추천 코스를 저장하지 못했어요. 다시 시도해주세요.',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final effectiveDayCount = courses.length;
    final selectedDay = _selectedDay.clamp(1, effectiveDayCount);
    final course = courses[selectedDay - 1];
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Hero(
              durationText: '${_startDate.month}월 추천 · $_durationText',
              destination: widget.destination,
              title: widget.title,
              tags: widget.tags,
              backgroundImage:
                  widget.backgroundImage ??
                  const AssetImage(AppImages.travelMockup),
              onBack: () => Navigator.of(context).maybePop(),
            ),
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
                    dayCount: effectiveDayCount,
                    selectedDay: selectedDay,
                    onChanged: (day) => setState(() => _selectedDay = day),
                  ),
                  const SizedBox(height: 10),
                  _CourseCard(
                    course: course,
                    pageCount: courses.length,
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
                  AppButton(
                    text: _isSaving ? '코스를 저장하는 중...' : '이 코스 따라하기',
                    isEnabled: !_isSaving,
                    onPressed: _handlePrimaryTap,
                  ),
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
  const _Hero({
    required this.durationText,
    required this.destination,
    required this.title,
    required this.tags,
    required this.backgroundImage,
    required this.onBack,
  });
  final String durationText;
  final String destination;
  final String title;
  final List<String> tags;
  final ImageProvider<Object> backgroundImage;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: backgroundImage, fit: BoxFit.cover),
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
                  title,
                  style: AppTextStyles.body.copyWith(color: AppColors.gray2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      destination,
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      durationText,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final tag in tags) AppInfoTag(label: '# $tag'),
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
  const _CourseCard({
    required this.course,
    required this.pageCount,
    required this.onTap,
  });
  final TravelCourseModel course;
  final int pageCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppMapCard(
          title: course.firstSpotName,
          markers: [
            for (final spot in course.spots)
              MapMarker(
                position: LatLng(spot.latitude, spot.longitude),
                label: spot.name,
              ),
          ],
          currentPage: course.dayNumber - 1,
          pageCount: pageCount,
          onCourseTap: onTap,
        ),
        Positioned(
          top: 0,
          right: 0,
          width: 120,
          height: 48,
          child: Semantics(
            button: true,
            label: '코스 보기',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
