import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

const double _kStartLeftPadding = 21.0;

const double _kStartRightPadding = 49.0;

const double _kEndLeftPadding = 24.0;

const double _kEndRightPadding = 40.0;

double _measureTextWidth(String text, TextStyle style, TextScaler textScaler) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

class AppTravelDate extends StatefulWidget {
  const AppTravelDate({
    super.key,
    required this.startDate,
    required this.endDate,
    this.showTitle = true,
    this.onTap,
  });

  final DateTime startDate;
  final DateTime endDate;

  final bool showTitle;

  final VoidCallback? onTap;

  @override
  State<AppTravelDate> createState() => _AppTravelDateState();
}

enum _TravelDateSelection { start, end }

class _AppTravelDateState extends State<AppTravelDate> {
  _TravelDateSelection _selection = _TravelDateSelection.start;

  String _formatDate(DateTime date) => '${date.month}월 ${date.day}일';

  void _select(_TravelDateSelection selection) {
    if (_selection != selection) {
      setState(() => _selection = selection);
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = _formatDate(widget.startDate);
    final formattedEndDate = _formatDate(widget.endDate);
    final isStartSelected = _selection == _TravelDateSelection.start;
    final textScaler = MediaQuery.textScalerOf(context);

    final startTextWidth = math.max(
      _measureTextWidth('여행 시작일', AppTextStyles.body, textScaler),
      _measureTextWidth(formattedStartDate, AppTextStyles.subTitle, textScaler),
    );
    final endTextWidth = math.max(
      _measureTextWidth('여행 종료일', AppTextStyles.body, textScaler),
      _measureTextWidth(formattedEndDate, AppTextStyles.subTitle, textScaler),
    );
    final startShapeWidth =
        _kStartLeftPadding + startTextWidth + _kStartRightPadding;
    final endShapeWidth = _kEndLeftPadding + endTextWidth + _kEndRightPadding;
    final totalWidth = startShapeWidth + endShapeWidth;

    return Semantics(
      label: '여행 시작일 $formattedStartDate, 여행 종료일 $formattedEndDate',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const _TravelDateTitle(),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: totalWidth,
            height: 66,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipPath(
                    clipper: const _EndDateClipper(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      color: isStartSelected
                          ? AppColors.gray2
                          : AppColors.purple1,
                    ),
                  ),
                ),
                Positioned(
                  left: startShapeWidth + _kEndLeftPadding,
                  width: endTextWidth,
                  top: 0,
                  bottom: 0,
                  child: _DateText(label: '여행 종료일', date: formattedEndDate),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: startShapeWidth,
                  child: ClipPath(
                    clipper: const _StartDateClipper(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      color: isStartSelected
                          ? AppColors.purple1
                          : AppColors.gray2,
                    ),
                  ),
                ),
                Positioned(
                  left: _kStartLeftPadding,
                  width: startTextWidth,
                  top: 0,
                  bottom: 0,
                  child: _DateText(
                    label: '여행 시작일',
                    date: formattedStartDate,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: startShapeWidth,
                  child: Semantics(
                    button: true,
                    selected: isStartSelected,
                    label: '여행 시작일 $formattedStartDate',
                    child: GestureDetector(
                      onTap: () => _select(_TravelDateSelection.start),
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                ),
                Positioned(
                  left: startShapeWidth,
                  top: 0,
                  bottom: 0,
                  width: endShapeWidth,
                  child: Semantics(
                    button: true,
                    selected: !isStartSelected,
                    label: '여행 종료일 $formattedEndDate',
                    child: GestureDetector(
                      onTap: () => _select(_TravelDateSelection.end),
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 8,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 38,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              date,
              maxLines: 1,
              style: AppTextStyles.subTitle.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartDateClipper extends CustomClipper<Path> {
  const _StartDateClipper();

  static const double arrowWidth = 30;

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

  static const double arrowWidth = 30;

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

@Preview(group: 'hycho', name: 'Travel Date', size: Size.fromHeight(220))
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
