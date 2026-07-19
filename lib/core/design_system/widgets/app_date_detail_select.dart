import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppDateDetailSelect extends StatefulWidget {
  const AppDateDetailSelect({
    super.key,
    required this.dayCount,
    this.selectedDay,
    this.initialDay = 1,
    this.onChanged,
  }) : assert(dayCount >= 1 && dayCount <= 4),
       assert(initialDay >= 1 && initialDay <= dayCount),
       assert(selectedDay == null || selectedDay >= 1),
       assert(selectedDay == null || selectedDay <= dayCount);

  final int dayCount;
  final int? selectedDay;
  final int initialDay;
  final ValueChanged<int>? onChanged;

  @override
  State<AppDateDetailSelect> createState() => _AppDateDetailSelectState();
}

class _AppDateDetailSelectState extends State<AppDateDetailSelect> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay ?? widget.initialDay;
  }

  @override
  void didUpdateWidget(AppDateDetailSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextSelectedDay = widget.selectedDay ?? _selectedDay;
    _selectedDay = nextSelectedDay.clamp(1, widget.dayCount);
  }

  void _handleTap(int day) {
    if (_selectedDay == day) return;

    if (widget.selectedDay == null) {
      setState(() => _selectedDay = day);
    }

    widget.onChanged?.call(day);
  }

  double get _indicatorWidthRatio {
    return switch (widget.dayCount) {
      1 => 1,
      2 => 173 / 345,
      3 => 107 / 345,
      4 => 79 / 345,
      _ => throw StateError('dayCount는 1부터 4까지만 지원합니다.'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final indicatorAlignmentX = widget.dayCount == 1
        ? 0.0
        : -1 + 2 * ((_selectedDay - 1) / (widget.dayCount - 1));

    return SizedBox(
      width: double.infinity,
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment(indicatorAlignmentX, 0),
                  child: FractionallySizedBox(
                    widthFactor: _indicatorWidthRatio,
                    heightFactor: 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.purple3,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ),
              ...List.generate(widget.dayCount, (index) {
                final day = index + 1;
                final isSelected = day == _selectedDay;
                final alignmentX = widget.dayCount == 1
                    ? 0.0
                    : -1 + 2 * (index / (widget.dayCount - 1));

                return Positioned.fill(
                  child: Align(
                    alignment: Alignment(alignmentX, 0),
                    child: FractionallySizedBox(
                      widthFactor: _indicatorWidthRatio,
                      heightFactor: 1,
                      child: Center(
                        child: Text(
                          '$day일차',
                          maxLines: 1,
                          style: AppTextStyles.body.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.gray5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Row(
                children: List.generate(widget.dayCount, (index) {
                  final day = index + 1;
                  final isSelected = day == _selectedDay;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: '$day일차',
                      child: GestureDetector(
                        onTap: () => _handleTap(day),
                        behavior: HitTestBehavior.opaque,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Date Detail - 1일')
Widget appDateDetailOneDayPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppDateDetailSelect(dayCount: 1),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Date Detail - 2일')
Widget appDateDetailTwoDaysPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppDateDetailSelect(dayCount: 2),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Date Detail - 3일')
Widget appDateDetailThreeDaysPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppDateDetailSelect(dayCount: 3),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Date Detail - 4일')
Widget appDateDetailFourDaysPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppDateDetailSelect(dayCount: 4),
      ),
    ),
  );
}
