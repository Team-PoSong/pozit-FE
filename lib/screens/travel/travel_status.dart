import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_system/app_icons.dart';

class TravelStatusIndicator extends StatelessWidget {
  const TravelStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218,
      child: Row(
        children: [
          _StatusItem(
            icon: AppIcons.travelVisited,
            label: '방문완료',
            textColor: const Color(0xFF161424), // TODO: 디자인 시스템 나오면 해당하는 색상으로 교체 필요
          ),
          _StatusItem(
            icon: AppIcons.travelVisiting,
            label: '방문중',
            textColor: const Color(0xFF161424), // TODO: 디자인 시스템 나오면 해당하는 색상으로 교체 필요
          ),
          _StatusItem(
            icon: AppIcons.travelWillVisit,
            label: '미방문',
            textColor: const Color(0xFF161424), // TODO: 디자인 시스템 나오면 해당하는 색상으로 교체 필요
          ),
        ],
      ),
    );
  }
}

// 컴포넌트 구현 시 반드시 preview 함수 추가하여 컴포넌트가 정상적으로 작동하는지 확인, 캡쳐하여 PR에 첨부
@Preview()
Widget travelStatusIndicatorPreview() => const TravelStatusIndicator();

class _StatusItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color textColor;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218 / 3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle( // TODO: 디자인 시스템 나오면 해당하는 스타일로 교체 필요
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}