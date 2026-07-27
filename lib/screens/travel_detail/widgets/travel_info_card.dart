import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/progress/app_completion_progress_bar.dart';
import '../../../data/models/travel_info_card_model.dart';

const TextStyle _tagTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 10,
  fontWeight: FontWeight.w500,
  height: 14 / 10,
  letterSpacing: 0,
  color: AppColors.gray5,
);

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
                    flex: 3,
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
                  Flexible(
                    flex: 2,
                    child: Text(
                      '${info.dateRangeText} · ${info.durationText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
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
                _InfoTag(label: visibleTags[i]),
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
              '${(info.completionRate * 100).round()}%',
              style: AppTextStyles.body.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = label.startsWith('#') ? label : '# $label';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.gray5, width: 0.5),
        ),
      ),
      child: Text(text, style: _tagTextStyle),
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
