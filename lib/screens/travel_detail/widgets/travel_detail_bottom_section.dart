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
const double _kPosingToButtonGap = 30.0;

const double _kTicketToTextGap = 21.0;

const double _kCarrierTicketWidth = 121.0;

const double _kBottomSafeGap = 7.0;

class TravelDetailBottomSection extends StatelessWidget {
  const TravelDetailBottomSection({
    super.key,
    required this.status,
    required this.companionCount,
    this.onSaveLogTap,
    this.cameraKey,
  });

  final AppTravelStatus status;
  final int companionCount;
  final VoidCallback? onSaveLogTap;
  final Key? cameraKey;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppTravelStatus.upcoming:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kBottomSafeGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image(
                  image: const AssetImage(AppImages.carrierTicket),
                  width: _kCarrierTicketWidth,
                ),
              ),
              const SizedBox(height: _kTicketToTextGap),
              Text(
                '여행이 시작되면 기록할 수 있어요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      case AppTravelStatus.inProgress:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kBottomSafeGap,
          ),
          child: _PosingColumn(
            companionCount: companionCount,
            cameraKey: cameraKey,
          ),
        );
      case AppTravelStatus.completed:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kBottomSafeGap,
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
  const _PosingColumn({required this.companionCount, this.cameraKey});

  final int companionCount;
  final Key? cameraKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < companionCount; i++) ...[
          if (i > 0) const SizedBox(height: _kPosingGap),
          AppPosing(key: i == 0 ? cameraKey : null, isCameraOn: false),
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
