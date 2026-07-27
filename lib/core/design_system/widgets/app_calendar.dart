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

const double _cellWidth = 18.0;
const double _cellGap = 26.0;
const double _rowContentWidth = (_cellWidth + _cellGap) * 6 + _cellWidth; // 282.0
const double _capPaddingHorizontal = 7.0; // 텍스트 좌우로 확장되는 정도
const double _capPaddingVertical = 4.0; // 텍스트 위아래로 확장되는 정도

class _HighlightSegment {
  final Rect rect;
  final bool roundLeft; // 진짜 시작일이면 true(둥글게), 줄바꿈으로 이어지는 중이면 false(각지게)
  final bool roundRight;

  const _HighlightSegment({
    required this.rect,
    required this.roundLeft,
    required this.roundRight,
  });
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// 여행 날짜(기간) 선택용 캘린더.
/// 날짜 숫자는 요일 줄과 완전히 동일한 단순 Row 구조로 그리고,
/// 선택 표시(진보라 도형)는 실제로 렌더링된 숫자 위치를 GlobalKey로 측정해서
/// 그 위에 별도 레이어로 얹는 방식. 좌표를 손으로 계산하지 않아서 정렬이 어긋날 수 없음.
class AppCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final double width;
  final void Function(DateTime start, DateTime end)? onRangeSelected;
  final VoidCallback? onSelectionCleared;

  AppCalendar({
    super.key,
    DateTime? initialMonth,
    this.width = 345.0,
    this.onRangeSelected,
    this.onSelectionCleared,
  }) : initialMonth = initialMonth ?? DateTime.now();

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _displayedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final GlobalKey _gridKey = GlobalKey();
  final Map<String, GlobalKey> _cellKeys = {};
  List<_HighlightSegment> _highlightRects = [];

  static const List<String> _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
    _scheduleMeasure();
  }

  GlobalKey _keyFor(DateTime date) =>
      _cellKeys.putIfAbsent(_dateKey(date), () => GlobalKey());

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHighlights());
  }

  void _measureHighlights() {
    if (!mounted) return;
    if (_rangeStart == null) {
      if (_highlightRects.isNotEmpty) setState(() => _highlightRects = []);
      return;
    }
    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null) return;

    final dates = _buildGridDates();
    final weeks = <List<DateTime>>[
      for (int i = 0; i < dates.length; i += 7) dates.sublist(i, i + 7),
    ];

    final rects = <_HighlightSegment>[];
    for (final week in weeks) {
      int? segStart;
      for (int i = 0; i < 7; i++) {
        final inRange = _isInRange(week[i]) && week[i].month == _displayedMonth.month;
        if (inRange) segStart ??= i;
        final isLastOfWeek = i == 6;
        if ((!inRange || isLastOfWeek) && segStart != null) {
          final segEnd = inRange ? i : i - 1;
          final startBox =
          _keyFor(week[segStart]).currentContext?.findRenderObject() as RenderBox?;
          final endBox =
          _keyFor(week[segEnd]).currentContext?.findRenderObject() as RenderBox?;
          if (startBox != null && endBox != null) {
            final startPos = startBox.localToGlobal(Offset.zero, ancestor: gridBox);
            final endPos = endBox.localToGlobal(Offset.zero, ancestor: gridBox);

            final isTrueStart = _isSameDay(week[segStart], _rangeStart!);
            final isTrueEnd = _rangeEnd != null
                ? _isSameDay(week[segEnd], _rangeEnd!)
                : _isSameDay(week[segEnd], _rangeStart!); // 종료일 없으면 시작일 자체가 곧 끝

            final double left = isTrueStart
                ? startPos.dx - _capPaddingHorizontal
                : (segStart == 0 ? 0.0 : startPos.dx);

            final double right = isTrueEnd
                ? endPos.dx + endBox.size.width + _capPaddingHorizontal
                : (segEnd == 6 ? _rowContentWidth : endPos.dx + endBox.size.width);

            rects.add(_HighlightSegment(
              rect: Rect.fromLTRB(
                left,
                startPos.dy - _capPaddingVertical,
                right,
                startPos.dy + startBox.size.height + _capPaddingVertical,
              ),
              roundLeft: isTrueStart,
              roundRight: isTrueEnd,
            ));
          }
          segStart = null;
        }
      }
    }
    setState(() => _highlightRects = rects);
  }

  void _goToPrevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
    _scheduleMeasure();
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
    _scheduleMeasure();
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_rangeStart == null) {
        _rangeStart = date;
        _rangeEnd = null;
      } else if (_rangeEnd == null) {
        if (_isSameDay(date, _rangeStart!)) {
          _rangeEnd = date;
        } else if (date.isBefore(_rangeStart!)) {
          _rangeStart = null;
          _rangeEnd = null;
        } else {
          _rangeEnd = date;
        }
      } else {
        final isStrictlyBetween = date.isAfter(_rangeStart!) && date.isBefore(_rangeEnd!);
        if (isStrictlyBetween) {
          _rangeStart = null;
          _rangeEnd = null;
        } else {
          _rangeStart = date;
          _rangeEnd = null;
        }
      }
    });
    _scheduleMeasure();

    if (_rangeStart == null && _rangeEnd == null) {
      widget.onSelectionCleared?.call();
    } else if (_rangeStart != null && _rangeEnd != null) {
      widget.onRangeSelected?.call(_rangeStart!, _rangeEnd!);
    }
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null) return false;
    if (_rangeEnd == null) return _isSameDay(date, _rangeStart!);
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
    final e = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  List<DateTime> _buildGridDates() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7;
    final gridStart = firstDayOfMonth.subtract(Duration(days: startWeekday));

    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return List.generate(totalCells, (i) => gridStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildGridDates();
    final weeks = <List<DateTime>>[
      for (int i = 0; i < dates.length; i += 7) dates.sublist(i, i + 7),
    ];
    // 요일 줄·날짜 그리드는 왼쪽 고정 패딩만으로 배치되므로(그리드 자체는
    // 내용만큼만 차지), 이 패딩을 너비에 맞춰 계산해야 컨테이너 안에서
    // 계속 정중앙에 위치합니다.
    final gridLeftPadding = ((widget.width - _rowContentWidth) / 2).clamp(
      0.0,
      double.infinity,
    );

    return Container(
      width: widget.width,
      padding: const EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: AppColors.gray3, blurRadius: 4.0)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 30.0),
            child: SizedBox(
              height: 24.0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _goToPrevMonth,
                    child: SvgPicture.asset(
                      AppIcons.arrowLeftSmallPurple,
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_displayedMonth.month}월',
                        style: AppTextStyles.headline.copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToNextMonth,
                    child: SvgPicture.asset(
                      AppIcons.arrowRightSmallPurple,
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34.0),
          Padding(
            padding: EdgeInsets.only(left: gridLeftPadding),
            child: Row(
              children: [
                for (int i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: _cellGap),
                  SizedBox(
                    width: _cellWidth,
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
            padding: EdgeInsets.only(left: gridLeftPadding),
            // 도형 레이어(측정된 위치)를 숫자 Column 밑에 깔고, 숫자는 그 위에 그대로 그림
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final seg in _highlightRects)
                  Positioned.fromRect(
                    rect: seg.rect,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.horizontal(
                          left: seg.roundLeft ? const Radius.circular(999.0) : Radius.zero,
                          right: seg.roundRight ? const Radius.circular(999.0) : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                Column(
                  key: _gridKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final week in weeks) ...[
                      Row(
                        children: [
                          for (int i = 0; i < 7; i++) ...[
                            if (i > 0) const SizedBox(width: _cellGap),
                            _DateCell(
                              key: _keyFor(week[i]),
                              date: week[i],
                              isCurrentMonth: week[i].month == _displayedMonth.month,
                              isInRange: _isInRange(week[i]),
                              onTap: _onDateTap,
                            ),
                          ],
                        ],
                      ),
                      if (week != weeks.last) const SizedBox(height: 18.0),
                    ],
                  ],
                ),
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
  final bool isInRange;
  final ValueChanged<DateTime>? onTap;

  const _DateCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isInRange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (!isCurrentMonth) {
      color = AppColors.gray4;
    } else if (isInRange) {
      color = AppColors.white;
    } else {
      color = AppColors.text;
    }

    return GestureDetector(
      onTap: isCurrentMonth ? () => onTap?.call(date) : null,
      child: SizedBox(
        width: _cellWidth,
        child: Text(
          '${date.day}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppCalendar - 인터랙티브')
Widget appCalendarInteractivePreview() => AppCalendar(
  initialMonth: DateTime(2026, 7),
  onRangeSelected: (start, end) {
    debugPrint('선택됨: $start ~ $end');
  },
);