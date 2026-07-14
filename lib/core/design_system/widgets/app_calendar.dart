import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../app_icons.dart';

import '../app_text_styles.dart';

const TextStyle _weekdayTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: AppColors.primary,
);

class AppCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final Set<DateTime> selectedDates; // 여행 일자로 선택된 날짜
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  const AppCalendar({
    super.key,
    required this.displayedMonth,
    this.selectedDates = const {},
    this.onDateSelected,
    this.onPrevMonth,
    this.onNextMonth,
  });

  static const List<String> _weekdayLabels = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  List<DateTime> _buildGridDates() {
    final firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final startWeekday = firstDayOfMonth.weekday % 7;
    final gridStart = firstDayOfMonth.subtract(Duration(days: startWeekday));

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return List.generate(totalCells, (i) => gridStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildGridDates();
    final weeks = <List<DateTime>>[
      for (int i = 0; i < dates.length; i += 7) dates.sublist(i, i + 7),
    ];

    return Container(
      width: 345.0,
      padding: const EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: AppColors.gray3, blurRadius: 4.0)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 30.0),
            child: SizedBox(
              height: 24.0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onPrevMonth,
                    child: SvgPicture.asset(
                      AppIcons.arrowLeftSmall,
                      width: 24.0,
                      height: 24.0,
                      colorFilter: const ColorFilter.mode(
                        AppColors.purple3,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${displayedMonth.month}월',
                        style: AppTextStyles.headline.copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onNextMonth,
                    child: SvgPicture.asset(
                      AppIcons.arrowRightSmall,
                      width: 24.0,
                      height: 24.0,
                      colorFilter: const ColorFilter.mode(
                        AppColors.purple3,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34.0),
          Padding(
            padding: const EdgeInsets.only(left: 31.0),
            child: Row(
              children: [
                for (int i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 26.0),
                  SizedBox(
                    width: 18.0,
                    child: Text(
                      _weekdayLabels[i],
                      textAlign: TextAlign.center,
                      style: _weekdayTextStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          Padding(
            padding: const EdgeInsets.only(left: 31.0),
            child: Column(
              children: [
                for (final week in weeks) ...[
                  Row(
                    children: [
                      for (int i = 0; i < 7; i++) ...[
                        if (i > 0) const SizedBox(width: 26.0),
                        _DateCell(
                          date: week[i],
                          isCurrentMonth: week[i].month == displayedMonth.month,
                          isSelected: selectedDates.any(
                                (d) =>
                            d.year == week[i].year &&
                                d.month == week[i].month &&
                                d.day == week[i].day,
                          ),
                          onTap: onDateSelected,
                        ),
                      ],
                    ],
                  ),
                  if (week != weeks.last) const SizedBox(height: 18.0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final ValueChanged<DateTime>? onTap;

  const _DateCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final FontWeight weight;
    if (!isCurrentMonth) {
      color = AppColors.gray4; // 저번달/다음달
      weight = FontWeight.w500;
    } else if (isSelected) {
      color = AppColors.gray6; // 여행 일자로 선택됨
      weight = FontWeight.w400;
    } else {
      color = AppColors.text; // 이번달
      weight = FontWeight.w500;
    }

    return GestureDetector(
      onTap: isCurrentMonth ? () => onTap?.call(date) : null,
      child: SizedBox(
        width: 18.0,
        child: Text(
          '${date.day}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: weight,
            color: color,
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppCalendar - 6월(5주)')
Widget appCalendarFiveWeeksPreview() => AppCalendar(
  displayedMonth: DateTime(2026, 6),
  selectedDates: {
    DateTime(2026, 6, 6),
    DateTime(2026, 6, 7),
    DateTime(2026, 6, 8),
  },
);

@Preview(group: 'haerim', name: 'AppCalendar - 8월(6주)')
Widget appCalendarSixWeeksPreview() =>
    AppCalendar(displayedMonth: DateTime(2026, 8));