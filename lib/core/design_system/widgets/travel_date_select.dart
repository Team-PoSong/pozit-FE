import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppTravelDate extends StatelessWidget {
  const AppTravelDate({
    super.key,
    required this.startDate,
    required this.endDate,
    this.onTap,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) => '${date.month}월 ${date.day}일';

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = _formatDate(startDate);
    final formattedEndDate = _formatDate(endDate);

    return Semantics(
      button: onTap != null,
      label: '여행 시작일 $formattedStartDate, 여행 종료일 $formattedEndDate',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TravelDateTitle(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 128,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final startShapeWidth = width * 0.5;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ClipPath(
                          clipper: const _EndDateClipper(),
                          child: const ColoredBox(color: AppColors.gray2),
                        ),
                      ),
                      Positioned(
                        left: startShapeWidth + 26,
                        right: 20,
                        top: 0,
                        bottom: 0,
                        child: _DateText(
                          label: '여행 종료일',
                          date: formattedEndDate,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: startShapeWidth,
                        child: ClipPath(
                          clipper: const _StartDateClipper(),
                          child: const ColoredBox(color: AppColors.purple1),
                        ),
                      ),
                      Positioned(
                        left: 21,
                        width: math.max(0, startShapeWidth - 33),
                        top: 0,
                        bottom: 0,
                        child: _DateText(
                          label: '여행 시작일',
                          date: formattedStartDate,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelDateTitle extends StatelessWidget {
  const _TravelDateTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _DiamondDecoration(),
        const SizedBox(width: 8),
        Text(
          '여행날짜',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DiamondDecoration extends StatelessWidget {
  const _DiamondDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 5,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: const ColoredBox(
                color: AppColors.primary,
                child: SizedBox.square(dimension: 6),
              ),
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: const ColoredBox(
                color: AppColors.primary,
                child: SizedBox.square(dimension: 4),
              ),
            ),
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: const ColoredBox(
                color: AppColors.primary,
                child: SizedBox.square(dimension: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              maxLines: 1,
              style: AppTextStyles.subTitle.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartDateClipper extends CustomClipper<Path> {
  const _StartDateClipper();

  static const double arrowWidth = 45;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - arrowWidth, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - arrowWidth, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_StartDateClipper oldClipper) => false;
}

class _EndDateClipper extends CustomClipper<Path> {
  const _EndDateClipper();

  static const double arrowWidth = 75;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - arrowWidth, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - arrowWidth, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_EndDateClipper oldClipper) => false;
}

@Preview(group: 'hycho', name: 'Travel Date', size: Size.fromHeight(280))
Widget appTravelDatePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: AppTravelDate(
          startDate: DateTime(2026, 7, 3),
          endDate: DateTime(2026, 7, 5),
        ),
      ),
    ),
  );
}
