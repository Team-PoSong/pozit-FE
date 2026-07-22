import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_images.dart';

enum TravelStatusMode { traveling, notTraveling }

const TextStyle _statusTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 10,
  fontWeight: FontWeight.w400,
  height: 20 / 10,
  letterSpacing: -0.5,
  color: AppColors.text,
);

class TravelStatusIndicator extends StatelessWidget {
  final TravelStatusMode mode;

  const TravelStatusIndicator({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final bool isTraveling = mode == TravelStatusMode.traveling;

    return Container(
      height: 31.0,
      padding: EdgeInsets.only(
        left: isTraveling ? 8.0 : 13.0,
        right: isTraveling ? 8.39 : 9.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(9999.0),
        border: Border.all(color: AppColors.gray3, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isTraveling
            ? const [
          _CompletedItem(iconTextGap: 8.0),
          SizedBox(width: 12.12),
          _VisitingItem(),
          SizedBox(width: 16.39),
          _NotVisitedItem(iconTextGap: 7.0),
        ]
            : const [
          _CompletedItem(iconTextGap: 11.57),
          SizedBox(width: 11.57),
          _NotVisitedItem(iconTextGap: 11.57),
        ],
      ),
    );
  }
}

class _CompletedItem extends StatelessWidget {
  final double iconTextGap;

  const _CompletedItem({required this.iconTextGap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.purple2,
            border: Border.all(color: AppColors.purple3, width: 0.5),
          ),
        ),
        SizedBox(width: iconTextGap),
        const Text('방문완료', style: _statusTextStyle),
      ],
    );
  }
}

class _VisitingItem extends StatelessWidget {
  const _VisitingItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x669FA1FF),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3.0, 3.999, 3.066, 3.44),
            child: Image.asset(AppImages.posongVisiting),
          ),
        ),
        const SizedBox(width: 6.0),
        const Text('방문중', style: _statusTextStyle),
      ],
    );
  }
}

class _NotVisitedItem extends StatelessWidget {
  final double iconTextGap;

  const _NotVisitedItem({required this.iconTextGap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gray2,
            border: Border.all(color: AppColors.gray4, width: 1.0),
          ),
        ),
        SizedBox(width: iconTextGap),
        const Text('미방문', style: _statusTextStyle),
      ],
    );
  }
}

@Preview(group: 'haerim', name: 'TravelStatusIndicator - 3개(방문중 포함)')
Widget travelStatusIndicatorTravelingPreview() =>
    const TravelStatusIndicator(mode: TravelStatusMode.traveling);

@Preview(group: 'haerim', name: 'TravelStatusIndicator - 2개(방문중 제외)')
Widget travelStatusIndicatorNotTravelingPreview() =>
    const TravelStatusIndicator(mode: TravelStatusMode.notTraveling);