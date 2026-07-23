import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';
import '../../../core/design_system/widgets/app_posing.dart';
import '../../../core/design_system/widgets/button/app_button.dart';

const double _kHorizontalPadding = 24.0;
const double _kStatusToContentGap = 15.0;
const double _kPosingGap = 12.0;
const double _kPosingToButtonGap = 33.0;
const double _kBottomTextPadding = 14.0;

/// 여행 상세 화면에서 [status]에 따라 달라지는 하단 영역입니다.
///
/// - 여행 전: 탑승권 이미지와 "여행이 시작되면 기록할 수 있어요." 안내 문구
/// - 여행 중: 동행인 수만큼의 [AppPosing]
/// - 여행 후: 여행 중과 동일한 [AppPosing]과 "여행 로그 저장하기" 버튼
class TravelDetailBottomSection extends StatelessWidget {
  const TravelDetailBottomSection({
    super.key,
    required this.status,
    required this.companionCount,
    this.onSaveLogTap,
  });

  final AppTravelStatus status;
  final int companionCount;
  final VoidCallback? onSaveLogTap;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppTravelStatus.upcoming:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: _kStatusToContentGap),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
              child: Center(child: Image(image: AssetImage(AppImages.carrierTicket))),
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _kHorizontalPadding,
                0,
                _kHorizontalPadding,
                _kBottomTextPadding,
              ),
              child: Text(
                '여행이 시작되면 기록할 수 있어요.',
                style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
              ),
            ),
          ],
        );
      case AppTravelStatus.inProgress:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            0,
          ),
          child: _PosingColumn(companionCount: companionCount),
        );
      case AppTravelStatus.completed:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PosingColumn(companionCount: companionCount),
              const SizedBox(height: _kPosingToButtonGap),
              AppButton(text: '여행 로그 저장하기', onPressed: onSaveLogTap),
            ],
          ),
        );
    }
  }
}

class _PosingColumn extends StatelessWidget {
  const _PosingColumn({required this.companionCount});

  final int companionCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < companionCount; i++) ...[
          if (i > 0) const SizedBox(height: _kPosingGap),
          const AppPosing(isCameraOn: false),
        ],
      ],
    );
  }
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 전')
Widget travelDetailBottomSectionUpcomingPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 300,
        child: TravelDetailBottomSection(
          status: AppTravelStatus.upcoming,
          companionCount: 3,
        ),
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 중')
Widget travelDetailBottomSectionInProgressPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailBottomSection(
        status: AppTravelStatus.inProgress,
        companionCount: 3,
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 후')
Widget travelDetailBottomSectionCompletedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailBottomSection(
        status: AppTravelStatus.completed,
        companionCount: 3,
      ),
    ),
  );
}
