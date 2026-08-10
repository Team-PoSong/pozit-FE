import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_calendar.dart';
import '../../core/design_system/widgets/app_travel_date_select.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_creation_data.dart';
import 'travel_info_screen.dart';

class TravelScheduleScreen extends StatefulWidget {
  const TravelScheduleScreen({
    super.key,
    required this.destination,
    this.onNext,
    this.onBackTap,
    this.minimumDate,
    this.creationMethod = TravelCreationMethod.create,
  });

  final String destination;
  final ValueChanged<DateTimeRange>? onNext;
  final VoidCallback? onBackTap;
  final DateTime? minimumDate;
  final TravelCreationMethod creationMethod;

  @override
  State<TravelScheduleScreen> createState() => _TravelScheduleScreenState();
}

class _TravelScheduleScreenState extends State<TravelScheduleScreen> {
  static const int _maximumTripNights = 3;
  static const String _maximumTripLengthMessage = '아직 포짓에서는 3박 4일까지만 지원해요';

  DateTime? _startDate;
  DateTime? _endDate;
  AppTravelDateSelection _activeSelection = AppTravelDateSelection.start;
  bool _hasCompleteRange = false;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool get _exceedsMaximumTripLength =>
      _startDate != null &&
      _endDate != null &&
      _endDate!.difference(_startDate!).inDays > _maximumTripNights;

  bool get _canContinue => _hasCompleteRange && !_exceedsMaximumTripLength;

  void _handleSelectionStarted(DateTime start) {
    setState(() {
      _startDate = start;
      _endDate = null;
      _activeSelection = AppTravelDateSelection.end;
      _hasCompleteRange = false;
    });
  }

  void _handleRangeSelected(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _hasCompleteRange = true;
    });
  }

  void _handleSelectionCleared() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _activeSelection = AppTravelDateSelection.start;
      _hasCompleteRange = false;
    });
  }

  void _handleDateFieldSelectionChanged(AppTravelDateSelection selection) {
    setState(() {
      _activeSelection = selection;
      if (selection == AppTravelDateSelection.start) {
        _hasCompleteRange = false;
      }
    });
  }

  void _handleBack() {
    final onBackTap = widget.onBackTap;
    if (onBackTap != null) {
      onBackTap();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleNext() {
    if (!_canContinue) return;
    final range = DateTimeRange(start: _startDate!, end: _endDate!);
    final onNext = widget.onNext;
    if (onNext != null) {
      onNext(range);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelInfoScreen(
          destination: widget.destination,
          dateRange: range,
          creationMethod: widget.creationMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minimumDate = _dateOnly(widget.minimumDate ?? DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 0),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '여행 일정을 알려주세요.',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppTravelDate(
                startDate: _startDate,
                endDate: _endDate,
                showTitle: false,
                activeSelection: _activeSelection,
                onSelectionChanged: _handleDateFieldSelectionChanged,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCalendar(
                      initialMonth: minimumDate,
                      minSelectableDate: minimumDate,
                      selectionTarget:
                          _activeSelection == AppTravelDateSelection.start
                          ? AppCalendarSelectionTarget.start
                          : AppCalendarSelectionTarget.end,
                      onSelectionStarted: _handleSelectionStarted,
                      onRangeSelected: _handleRangeSelected,
                      onSelectionCleared: _handleSelectionCleared,
                    ),
                    if (_exceedsMaximumTripLength) ...[
                      const SizedBox(height: 8),
                      Text(
                        _maximumTripLengthMessage,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '다음',
                isEnabled: _canContinue,
                onPressed: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Schedule', size: Size(393, 852))
Widget travelScheduleScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelScheduleScreen(
        destination: '경상북도 경주시',
        minimumDate: DateTime(2026, 7, 1),
      ),
    ),
  );
}
