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

const double _cellDiameter = 41.0;
const double _cellHeight = 32.0;
const double _cellGap = 3.0;
const double _rowContentWidth = _cellDiameter * 7 + _cellGap * 6;
const double _calendarHorizontalPadding = 20.0;
const double _weekRowGap = 8.0;
const double _fadeStop = 0.9634;

const double _arrowTouchSize = 48.0;
const double _arrowIconSize = 24.0;

const double _headerHorizontalOverflow = 7.0;

const double _calendarOuterPadding =
    _calendarHorizontalPadding - _headerHorizontalOverflow;

enum _CapType { round, pill, fade }

class _HighlightPiece {
  final Rect rect;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius radius;

  const _HighlightPiece({
    required this.rect,
    this.color,
    this.gradient,
    this.radius = const BorderRadius.all(Radius.circular(999.0)),
  });
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

class AppCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final DateTime? initialRangeStart;
  final DateTime? initialRangeEnd;
  final DateTime? minSelectableDate;
  final bool isCompact;
  final void Function(DateTime start, DateTime end)? onRangeSelected;
  final VoidCallback? onSelectionCleared;

  AppCalendar({
    super.key,
    DateTime? initialMonth,
    this.initialRangeStart,
    this.initialRangeEnd,
    this.minSelectableDate,
    this.isCompact = false,
    this.onRangeSelected,
    this.onSelectionCleared,
  }) : assert(
         (initialRangeStart == null) == (initialRangeEnd == null),
         '초기 날짜 범위는 시작일과 종료일을 함께 전달해야 합니다.',
       ),
       assert(
         initialRangeStart == null ||
             initialRangeEnd == null ||
             !initialRangeStart.isAfter(initialRangeEnd),
         '초기 날짜 범위의 시작일은 종료일 이후일 수 없습니다.',
       ),
       initialMonth = initialMonth ?? initialRangeStart ?? DateTime.now();

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _displayedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final GlobalKey _gridKey = GlobalKey();
  final Map<String, GlobalKey> _cellKeys = {};
  List<_HighlightPiece> _highlightPieces = [];

  static const List<String> _weekdayLabels = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialRangeStart;
    _rangeEnd = widget.initialRangeEnd;
    _displayedMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
    _scheduleMeasure();
  }

  GlobalKey _keyFor(DateTime date) =>
      _cellKeys.putIfAbsent(_dateKey(date), () => GlobalKey());

  void _cleanupCellKeys() {
    final validKeys = _buildGridDates().map(_dateKey).toSet();
    _cellKeys.removeWhere((key, _) => !validKeys.contains(key));
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHighlights());
  }

  bool _isDisabled(DateTime date) {
    final min = widget.minSelectableDate;
    if (min == null) return false;

    final d = DateTime(date.year, date.month, date.day);
    final m = DateTime(min.year, min.month, min.day);

    return d.isBefore(m);
  }

  bool _isEndpoint(DateTime date) {
    if (_rangeStart != null && _isSameDay(date, _rangeStart!)) return true;
    if (_rangeEnd != null && _isSameDay(date, _rangeEnd!)) return true;
    return false;
  }

  bool _isDisplayedMonth(DateTime date) =>
      date.year == _displayedMonth.year && date.month == _displayedMonth.month;

  Rect? _cellRect(DateTime date, RenderBox gridBox) {
    final box = _keyFor(date).currentContext?.findRenderObject() as RenderBox?;

    if (box == null) return null;

    final pos = box.localToGlobal(Offset.zero, ancestor: gridBox);

    return pos & box.size;
  }

  void _measureHighlights() {
    if (!mounted) return;

    if (_rangeStart == null) {
      if (_highlightPieces.isNotEmpty) {
        setState(() => _highlightPieces = []);
      }
      return;
    }

    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (gridBox == null) return;

    final dates = _buildGridDates();

    final weeks = <List<DateTime>>[
      for (int i = 0; i < dates.length; i += 7) dates.sublist(i, i + 7),
    ];

    final trueStart = _rangeStart!;
    final trueEnd = _rangeEnd ?? _rangeStart!;

    final monthFirstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final monthLastDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );

    final startsBeforeMonth = trueStart.isBefore(monthFirstDay);
    final endsAfterMonth = trueEnd.isAfter(monthLastDay);

    final pieces = <_HighlightPiece>[];

    for (final week in weeks) {
      int? segStart;

      for (int i = 0; i < 7; i++) {
        final inRange = _isInRange(week[i]) && _isDisplayedMonth(week[i]);

        if (inRange) segStart ??= i;

        final isLastOfWeek = i == 6;

        if ((!inRange || isLastOfWeek) && segStart != null) {
          final segEnd = inRange ? i : i - 1;

          _emitSegment(
            pieces: pieces,
            week: week,
            segStart: segStart,
            segEnd: segEnd,
            gridBox: gridBox,
            trueStart: trueStart,
            trueEnd: trueEnd,
            monthFirstDay: monthFirstDay,
            monthLastDay: monthLastDay,
            startsBeforeMonth: startsBeforeMonth,
            endsAfterMonth: endsAfterMonth,
          );

          segStart = null;
        }
      }
    }

    setState(() => _highlightPieces = pieces);
  }

  void _emitSegment({
    required List<_HighlightPiece> pieces,
    required List<DateTime> week,
    required int segStart,
    required int segEnd,
    required RenderBox gridBox,
    required DateTime trueStart,
    required DateTime trueEnd,
    required DateTime monthFirstDay,
    required DateTime monthLastDay,
    required bool startsBeforeMonth,
    required bool endsAfterMonth,
  }) {
    _CapType capTypeFor(int index) {
      final date = week[index];

      if (_isSameDay(date, trueStart) || _isSameDay(date, trueEnd)) {
        return _CapType.pill;
      }

      final isMonthFirst = startsBeforeMonth && _isSameDay(date, monthFirstDay);

      final isMonthLast = endsAfterMonth && _isSameDay(date, monthLastDay);

      if (isMonthFirst || isMonthLast) return _CapType.fade;

      return _CapType.round;
    }

    void addPiece(int index, _CapType type, {bool squareTouchingSide = false}) {
      final rect = _cellRect(week[index], gridBox);
      if (rect == null) return;

      if (type == _CapType.pill) {
        pieces.add(_HighlightPiece(rect: rect, color: AppColors.purple3));
      } else if (type == _CapType.fade) {
        final isLeftEdge =
            startsBeforeMonth && _isSameDay(week[index], monthFirstDay);

        pieces.add(
          _HighlightPiece(
            rect: rect,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isLeftEdge
                  ? [
                      AppColors.purple1.withValues(alpha: 0.0),
                      AppColors.purple1,
                    ]
                  : [
                      AppColors.purple1,
                      AppColors.purple1.withValues(alpha: 0.0),
                    ],
              stops: [0.0, _fadeStop],
            ),
            radius: !squareTouchingSide
                ? const BorderRadius.all(Radius.circular(999.0))
                : (isLeftEdge
                      ? const BorderRadius.horizontal(
                          left: Radius.circular(999.0),
                        )
                      : const BorderRadius.horizontal(
                          right: Radius.circular(999.0),
                        )),
          ),
        );
      }
    }

    if (segStart == segEnd) {
      final type = capTypeFor(segStart);

      if (type == _CapType.round) {
        final rect = _cellRect(week[segStart], gridBox);

        if (rect != null) {
          pieces.add(_HighlightPiece(rect: rect, color: AppColors.purple1));
        }
      } else {
        addPiece(segStart, type);
      }

      return;
    }

    final leftType = capTypeFor(segStart);
    final rightType = capTypeFor(segEnd);

    final startCellRect = _cellRect(week[segStart], gridBox);

    final endCellRect = _cellRect(week[segEnd], gridBox);

    if (startCellRect != null && endCellRect != null) {
      final left = leftType == _CapType.fade
          ? startCellRect.right
          : startCellRect.left;

      final right = rightType == _CapType.fade
          ? endCellRect.left
          : endCellRect.right;

      if (right > left) {
        pieces.add(
          _HighlightPiece(
            rect: Rect.fromLTRB(
              left,
              startCellRect.top,
              right,
              startCellRect.bottom,
            ),
            color: AppColors.purple1,
            radius: BorderRadius.horizontal(
              left: leftType == _CapType.fade
                  ? Radius.zero
                  : const Radius.circular(999.0),
              right: rightType == _CapType.fade
                  ? Radius.zero
                  : const Radius.circular(999.0),
            ),
          ),
        );
      }
    }

    if (leftType != _CapType.round) {
      addPiece(segStart, leftType, squareTouchingSide: true);
    }

    if (rightType != _CapType.round) {
      addPiece(segEnd, rightType, squareTouchingSide: true);
    }
  }

  void _goToPrevMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });

    _cleanupCellKeys();
    _scheduleMeasure();
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });

    _cleanupCellKeys();
    _scheduleMeasure();
  }

  void _onDateTap(DateTime date) {
    if (_isDisabled(date)) return;

    var selectionCleared = false;

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
          selectionCleared = true;
        } else {
          _rangeEnd = date;
        }
      } else {
        final isStrictlyBetween =
            date.isAfter(_rangeStart!) && date.isBefore(_rangeEnd!);

        if (isStrictlyBetween) {
          _rangeStart = null;
          _rangeEnd = null;
        } else {
          _rangeStart = date;
          _rangeEnd = null;
        }

        selectionCleared = true;
      }
    });

    _scheduleMeasure();

    if (selectionCleared) {
      widget.onSelectionCleared?.call();
    }

    if (_rangeStart != null && _rangeEnd != null) {
      widget.onRangeSelected?.call(_rangeStart!, _rangeEnd!);
    }
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null) return false;

    if (_rangeEnd == null) {
      return _isSameDay(date, _rangeStart!);
    }

    final d = DateTime(date.year, date.month, date.day);

    final s = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);

    final e = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);

    return !d.isBefore(s) && !d.isAfter(e);
  }

  List<DateTime> _buildGridDates() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final startWeekday = firstDayOfMonth.weekday % 7;

    final gridStart = firstDayOfMonth.subtract(Duration(days: startWeekday));

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return List.generate(totalCells, (i) => gridStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildGridDates();
    final outerBottomPadding = widget.isCompact ? 16.0 : 32.0;
    final headerTopGap = widget.isCompact ? 12.0 : 20.0;
    final headerToWeekdayGap = widget.isCompact ? 14.0 : 22.0;
    final weekdayToGridGap = widget.isCompact ? 10.0 : 14.0;

    final weeks = <List<DateTime>>[
      for (int i = 0; i < dates.length; i += 7) dates.sublist(i, i + 7),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: outerBottomPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: AppColors.gray3, blurRadius: 4.0)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _calendarOuterPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.isFinite
                ? (constraints.maxWidth - _headerHorizontalOverflow * 2)
                      .clamp(0.0, _rowContentWidth)
                      .toDouble()
                : _rowContentWidth;

            var cellWidth = _cellDiameter;
            var cellGap = _cellGap;

            const minCellGap = 1.0;
            const cellsWidth = _cellDiameter * 7;
            const widthAtMinGap = cellsWidth + 6 * minCellGap;

            if (contentWidth < _rowContentWidth) {
              if (contentWidth >= widthAtMinGap) {
                cellGap = (contentWidth - cellsWidth) / 6;
              } else {
                cellGap = minCellGap;
                cellWidth = (contentWidth - 6 * minCellGap) / 7;
              }
            }

            final rowWidth = cellWidth * 7 + cellGap * 6;

            final headerWidth = rowWidth + _headerHorizontalOverflow * 2;

            return Center(
              heightFactor: 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: headerTopGap),

                  SizedBox(
                    width: headerWidth,
                    height: _arrowTouchSize,
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _goToPrevMonth,
                          child: SizedBox.square(
                            dimension: _arrowTouchSize,
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.arrowLeftSmallPurple,
                                width: _arrowIconSize,
                                height: _arrowIconSize,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_displayedMonth.month}월',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _goToNextMonth,
                          child: SizedBox.square(
                            dimension: _arrowTouchSize,
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.arrowRightSmallPurple,
                                width: _arrowIconSize,
                                height: _arrowIconSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: headerToWeekdayGap),

                  SizedBox(
                    width: rowWidth,
                    child: Row(
                      children: [
                        for (int i = 0; i < 7; i++) ...[
                          if (i > 0) SizedBox(width: cellGap),
                          SizedBox(
                            width: cellWidth,
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

                  SizedBox(height: weekdayToGridGap),

                  NotificationListener<SizeChangedLayoutNotification>(
                    onNotification: (_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _measureHighlights();
                      });
                      return true;
                    },
                    child: SizeChangedLayoutNotifier(
                      child: SizedBox(
                        width: rowWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (final piece in _highlightPieces)
                              Positioned.fromRect(
                                rect: piece.rect,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: piece.gradient == null
                                        ? piece.color
                                        : null,
                                    gradient: piece.gradient,
                                    borderRadius: piece.radius,
                                  ),
                                ),
                              ),

                            Column(
                              key: _gridKey,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (
                                  int weekIndex = 0;
                                  weekIndex < weeks.length;
                                  weekIndex++
                                ) ...[
                                  Row(
                                    children: [
                                      for (int i = 0; i < 7; i++) ...[
                                        if (i > 0) SizedBox(width: cellGap),
                                        _DateCell(
                                          key: _keyFor(weeks[weekIndex][i]),
                                          width: cellWidth,
                                          date: weeks[weekIndex][i],
                                          isCurrentMonth: _isDisplayedMonth(
                                            weeks[weekIndex][i],
                                          ),
                                          isEndpoint: _isEndpoint(
                                            weeks[weekIndex][i],
                                          ),
                                          isDisabled: _isDisabled(
                                            weeks[weekIndex][i],
                                          ),
                                          onTap: _onDateTap,
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (weekIndex < weeks.length - 1)
                                    const SizedBox(height: _weekRowGap),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final double width;
  final DateTime date;
  final bool isCurrentMonth;
  final bool isEndpoint;
  final bool isDisabled;
  final ValueChanged<DateTime>? onTap;

  const _DateCell({
    super.key,
    required this.width,
    required this.date,
    required this.isCurrentMonth,
    required this.isEndpoint,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCurrentMonth) {
      return SizedBox(width: width, height: _cellHeight);
    }

    final Color color;

    if (isDisabled) {
      color = AppColors.gray4;
    } else if (isEndpoint) {
      color = AppColors.white;
    } else {
      color = AppColors.text;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : () => onTap?.call(date),
      child: SizedBox(
        width: width,
        height: _cellHeight,
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppCalendar - 인터랙티브', size: Size(409, 480))
Widget appCalendarInteractivePreview() => Align(
  alignment: Alignment.topCenter,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: AppCalendar(
      initialMonth: DateTime(2026, 7),
      onRangeSelected: (start, end) {
        debugPrint('선택됨: $start ~ $end');
      },
    ),
  ),
);

@Preview(
  group: 'haerim',
  name: 'AppCalendar - 오늘이 7월 9일이라면',
  size: Size(409, 480),
)
Widget appCalendarTodayJuly9Preview() => Align(
  alignment: Alignment.topCenter,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: AppCalendar(
      initialMonth: DateTime(2026, 7),
      minSelectableDate: DateTime(2026, 7, 9),
      onRangeSelected: (start, end) {
        debugPrint('선택됨: $start ~ $end');
      },
    ),
  ),
);
