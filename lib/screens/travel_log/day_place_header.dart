import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';

class DayPlaceHeader extends StatelessWidget {
  final int day;
  final String placeName;

  const DayPlaceHeader({
    super.key,
    required this.day,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9999.0),
        boxShadow: const [
          BoxShadow(color: Color(0x807E7E7E), blurRadius: 20.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26.0).copyWith(left: 45.0, right: 45.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Day $day',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 40.0,
                fontWeight: FontWeight.w700,
                color: AppColors.purple3,
              ),
            ),
            const SizedBox(width: 65.0),
            SvgPicture.asset(
              AppIcons.pinFilter,
              width: 48.0,
              height: 48.0,
              colorFilter: const ColorFilter.mode(AppColors.purple3, BlendMode.srcIn),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Text(
                placeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 39.244,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'DayPlaceHeader')
Widget dayPlaceHeaderPreview() => const DayPlaceHeader(day: 1, placeName: '동궁과월지');