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

/// 여행 상세 화면 상단에서 여행의 핵심 정보를 요약해 보여주는 카드입니다.
///
/// 여행 대표 이미지 등 배경 위에 올라간다는 전제로 텍스트가 흰색으로
/// 디자인되어 있으므로, 배경은 이 위젯을 사용하는 곳에서 준비해야 합니다.
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
            // destination과 date를 하나의 Expanded 안에 함께 넣어 이 블록이
            // 남는 공간을 전부 차지하게 합니다. 그래야 아래쪽 완주율
            // 퍼센티지와 오른쪽 끝이 정확히 맞고(뒤 아이콘/인원수가 항상
            // 카드 끝에 붙음), 여행지 이름이 길어져도 이 블록 안에서만
            // 줄어들어 카드 밖으로 오버플로우되지 않습니다.
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
    // 네, 내부 padding 값이 칩의 가로세로 비율을 그대로 좌우합니다. 세로
    // padding이 가로에 비해 크면 칩이 통통한 타원처럼 보이는데, 기존
    // (10, 5)는 세로 비중이 커서 그렇게 보였습니다. 세로를 줄이고 가로를
    // 늘려 더 얇고 넓은 필(pill) 형태로 조정했습니다. 디자인에 정확한
    // 수치가 있다면 그 값으로 다시 맞춰주세요.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const ShapeDecoration(
        color: AppColors.white,
        shape: StadiumBorder(
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
