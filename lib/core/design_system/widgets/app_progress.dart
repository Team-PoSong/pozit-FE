import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';

/// 여행 빡빡정도 선택 트랙
/// onLevelSelected로 선택 인덱스(0~2) 전달
class AppDensityTrack extends StatelessWidget {
  final ValueChanged<int>? onLevelSelected;

  const AppDensityTrack({super.key, this.onLevelSelected});

  static const double _width = 221.0;
  static const double _height = 13.0;
  static const List<double> _tickLeftOffsets = [10.0, 109.0, 208.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 5.0,
            child: Container(
              width: _width,
              height: 3.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.purple1, AppColors.purple2],
                ),
              ),
            ),
          ),
          for (final left in _tickLeftOffsets)
            Positioned(
              left: left,
              top: 0,
              child: Container(
                width: 3.0,
                height: _height,
                color: AppColors.purple2,
              ),
            ),
          Positioned.fill(
            child: Row(
              children: List.generate(
                3,
                    (index) => Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onLevelSelected?.call(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 완주율 프로그레스바
/// progress: 0.0 ~ 1.0
class AppCompletionProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const AppCompletionProgressBar({
    super.key,
    required this.progress,
    this.width = 242.0,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.purple1,
        borderRadius: BorderRadius.circular(9999.0),
        border: Border.all(color: AppColors.primary, width: 0.5),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0).toDouble(),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200.0),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.purple2, AppColors.purple3],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 일자별 세그먼트 바
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
            decoration: BoxDecoration(
              color: i == currentDayIndex
                  ? AppColors.purple3
                  : AppColors.purple1,
              borderRadius: BorderRadius.circular(9999.0),
            ),
          ),
        ],
      ],
    );
  }
}

@Preview(group: 'haerim', name: 'AppDensityTrack')
Widget appDensityTrackPreview() => const AppDensityTrack();

@Preview(group: 'haerim', name: 'AppCompletionProgressBar')
Widget appCompletionProgressBarPreview() =>
    const AppCompletionProgressBar(progress: 156 / 242);

@Preview(group: 'haerim', name: 'AppDaySegmentBar - 4일 중 3일차')
Widget appDaySegmentBarPreview() =>
    const AppDaySegmentBar(totalDays: 4, currentDayIndex: 2);