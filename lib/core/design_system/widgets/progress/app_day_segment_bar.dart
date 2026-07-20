import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';

class AppDaySegmentBar extends StatelessWidget {
  final int totalDays;
  final int currentDayIndex;

  const AppDaySegmentBar({
    super.key,
    required this.totalDays,
    required this.currentDayIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < totalDays; i++) ...[
          if (i > 0) const SizedBox(width: 8.0),
          Container(
            width: 50.0,
            height: 7.0,
            decoration: ShapeDecoration(
              color: i == currentDayIndex
                  ? AppColors.purple3
                  : AppColors.purple1,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ],
    );
  }
}

@Preview(group: 'haerim', name: 'AppDaySegmentBar - 4일 중 3일차')
Widget appDaySegmentBarPreview() =>
    const AppDaySegmentBar(totalDays: 4, currentDayIndex: 2);

@Preview(group: 'haerim', name: 'AppDaySegmentBar - 3일 중 2일차')
Widget appDaySegmentBarThreeStepPreview() =>
    const AppDaySegmentBar(totalDays: 3, currentDayIndex: 1);