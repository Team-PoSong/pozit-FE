import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../../travel_detail/widgets/travel_detail_top_bar.dart';

class TravelCreationHeader extends StatelessWidget {
  const TravelCreationHeader({
    super.key,
    required this.currentStepIndex,
    required this.onBackTap,
    this.trailing,
  });

  final int currentStepIndex;
  final VoidCallback onBackTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            TravelDetailTopBar(title: '여행 생성하기', onBackTap: onBackTap),
            if (trailing case final widget?)
              Positioned(right: 24, top: 14.5, child: widget),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: AppDaySegmentBar(
            totalDays: 3,
            currentDayIndex: currentStepIndex,
          ),
        ),
      ],
    );
  }
}
