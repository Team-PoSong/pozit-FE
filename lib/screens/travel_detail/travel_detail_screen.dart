import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_date_detail_select.dart';
import '../../core/design_system/widgets/app_map_card.dart';
import '../../data/models/travel_info_card_model.dart';
import 'widgets/travel_detail_bottom_section.dart';
import 'widgets/travel_detail_top_bar.dart';
import 'widgets/travel_info_card.dart';
import 'widgets/travel_status.dart';

const double _kPhotoHeightRatio = 0.34;
const double _kHorizontalPadding = 24.0;
const double _kTopBarToInfoCardGap = 38.0;
const double _kPhotoToDateSelectGap = 17.0;
const double _kDateSelectToMapCardGap = 10.0;
const double _kMapCardToStatusGap = 8.0;

/// 여행 상세 화면입니다.
///
/// 여행의 진행 상태([status])에 따라 하단 영역이 달라지며, 자세한 내용은
/// [TravelDetailBottomSection]을 참고하세요.
class TravelDetailScreen extends StatefulWidget {
  const TravelDetailScreen({
    super.key,
    required this.info,
    required this.status,
    this.backgroundImage = const AssetImage(AppImages.travelMockup),
    this.initialDay = 1,
    this.onBackTap,
    this.onSettingsTap,
    this.onMemberTap,
    this.onLeaveTap,
    this.onDeleteTap,
    this.onCourseTap,
    this.onDayChanged,
    this.onSaveLogTap,
  });

  final TravelInfoCardModel info;
  final AppTravelStatus status;
  final ImageProvider<Object> backgroundImage;
  final int initialDay;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMemberTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCourseTap;
  final ValueChanged<int>? onDayChanged;
  final VoidCallback? onSaveLogTap;

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> {
  late int _selectedDay = widget.initialDay;

  void _handleDayChanged(int day) {
    setState(() => _selectedDay = day);
    widget.onDayChanged?.call(day);
  }

  @override
  Widget build(BuildContext context) {
    final photoHeight = MediaQuery.sizeOf(context).height * _kPhotoHeightRatio;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: photoHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: widget.backgroundImage, fit: BoxFit.cover),
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TravelDetailTopBar는 자체적으로 좌우 16만큼의 아이콘
                      // 여백을 두므로, 바깥에서 다시 24 패딩을 주면 이중으로
                      // 밀려나 보입니다. 화면 폭 그대로 전달합니다.
                      TravelDetailTopBar(
                        title: widget.info.destination,
                        showSettingsButton: true,
                        travelStatus: widget.status,
                        iconColor: AppColors.white,
                        textColor: AppColors.white,
                        onBackTap: widget.onBackTap,
                        onSettingsTap: widget.onSettingsTap,
                        onMemberTap: widget.onMemberTap,
                        onLeaveTap: widget.onLeaveTap,
                        onDeleteTap: widget.onDeleteTap,
                      ),
                      const SizedBox(height: _kTopBarToInfoCardGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kHorizontalPadding,
                        ),
                        child: TravelInfoCard(info: widget.info),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: _kPhotoToDateSelectGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kHorizontalPadding,
                        ),
                        child: AppDateDetailSelect(
                          dayCount: widget.info.totalDays,
                          selectedDay: _selectedDay,
                          onChanged: _handleDayChanged,
                        ),
                      ),
                      const SizedBox(height: _kDateSelectToMapCardGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kHorizontalPadding,
                        ),
                        child: AppMapCard(
                          title: widget.info.firstPlaceOfDay(_selectedDay),
                          onCourseTap: widget.onCourseTap,
                        ),
                      ),
                      const SizedBox(height: _kMapCardToStatusGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kHorizontalPadding,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TravelStatusIndicator(
                            mode: widget.status == AppTravelStatus.inProgress
                                ? TravelStatusMode.traveling
                                : TravelStatusMode.notTraveling,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // hasScrollBody: false로 두면 남은 공간을 그대로 채우되,
                // 내용(예: 동행 인원이 많은 posing 목록)이 더 크면 그만큼
                // 이 스크롤뷰가 스크롤되어 하단 오버플로우를 막아줍니다.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: TravelDetailBottomSection(
                    status: widget.status,
                    companionCount: widget.info.companionCount,
                    onSaveLogTap: widget.onSaveLogTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

TravelInfoCardModel _previewInfo() {
  return TravelInfoCardModel(
    destination: '경주',
    startDate: DateTime(2026, 6, 5),
    endDate: DateTime(2026, 6, 7),
    companionCount: 3,
    tags: const ['기록', '미식'],
    visitedPlaceCount: 12,
    recordCount: 48,
    completionRate: 0.6,
    course: const [
      ['동궁과 월지', '첨성대'],
      ['불국사', '석굴암'],
      ['보문관광단지'],
    ],
  );
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 전', size: Size(390, 844))
Widget travelDetailScreenUpcomingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.upcoming,
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 중', size: Size(390, 844))
Widget travelDetailScreenInProgressPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.inProgress,
    ),
  );
}

@Preview(group: 'travel_detail', name: 'TravelDetailScreen - 여행 후', size: Size(390, 844))
Widget travelDetailScreenCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelDetailScreen(
      info: _previewInfo(),
      status: AppTravelStatus.completed,
    ),
  );
}
