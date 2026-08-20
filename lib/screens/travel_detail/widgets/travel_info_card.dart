import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/app_info_tag.dart';
import '../../../core/design_system/widgets/progress/app_completion_progress_bar.dart';
import '../../../data/models/travel/travel_info_card_model.dart';

class TravelInfoCard extends StatelessWidget {
  const TravelInfoCard({super.key, required this.info});

  final TravelInfoCardModel info;

  @override
  Widget build(BuildContext context) {
    final visibleTags = info.tags.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      info.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Text(
                    '${info.dateRangeText} · ${info.durationText}',
                    maxLines: 1,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AppIcons.mypageFilled,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${info.companionCount}',
              style: AppTextStyles.subTitle.copyWith(color: AppColors.white),
            ),
          ],
        ),
        if (visibleTags.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < visibleTags.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                AppInfoTag(label: visibleTags[i]),
              ],
            ],
          ),
        ],
        const SizedBox(height: 30),
        Row(
          children: [
            Text(
              '${info.visitedPlaceCount}개 장소 방문',
              style: AppTextStyles.caption.copyWith(color: AppColors.white),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 10, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              '${info.recordCount}개 기록',
              style: AppTextStyles.caption.copyWith(color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              '완주율',
              style: AppTextStyles.body.copyWith(color: AppColors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: AppCompletionProgressBar(progress: info.completionRate),
            ),
            const SizedBox(width: 8),
            Text(
              '${(info.completionRate.clamp(0.0, 1.0) * 100).round()}%',
              style: AppTextStyles.body.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(group: 'travel_detail', name: 'TravelInfoCard')
Widget travelInfoCardPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: AppColors.gray5,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 30),
          child: TravelInfoCard(
            info: TravelInfoCardModel(
              destination: '경주',
              startDate: DateTime(2026, 6, 5),
              endDate: DateTime(2026, 6, 7),
              companionCount: 4,
              tags: const ['기록', '미식'],
              visitedPlaceCount: 12,
              recordCount: 48,
              completionRate: 0,
            ),
          ),
        ),
      ),
    ),
  );
}
