import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/widgets/app_calendar.dart';
import '../../core/design_system/widgets/app_travel_date_select.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

const double _kHorizontalPadding = 24.0;
// TravelDetailTopBar가 자체적으로 위에 4px을 더 내려가므로, 탑 바 다음
// 요소와의 간격을 4px 줄여서 기획상 의도한 40px 간격을 유지합니다(40 → 36).
const double _kTopBarToTravelDateGap = 36.0;
const double _kTravelDateToCalendarGap = 21.0;

/// '여행 설정'의 "여행이 언제인가요?" 항목에서 진입하는, 여행 날짜를
/// 수정하는 화면입니다. [AppCalendar]에서 새 기간을 선택하고 저장을 누르면
/// 선택한 [DateTimeRange]를 반환하며 이전 화면으로 돌아갑니다.
class TravelDateEditScreen extends StatefulWidget {
  const TravelDateEditScreen({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    this.onBackTap,
  });

  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final VoidCallback? onBackTap;

  @override
  State<TravelDateEditScreen> createState() => _TravelDateEditScreenState();
}

class _TravelDateEditScreenState extends State<TravelDateEditScreen> {
  late DateTime _displayStartDate = widget.initialStartDate;
  late DateTime _displayEndDate = widget.initialEndDate;
  bool _canSave = true;

  void _handleRangeSelected(DateTime start, DateTime end) {
    setState(() {
      _displayStartDate = start;
      _displayEndDate = end;
      _canSave = true;
    });
  }

  void _handleSelectionCleared() {
    setState(() => _canSave = false);
  }

  void _handleSave() {
    Navigator.of(
      context,
    ).pop(DateTimeRange(start: _displayStartDate, end: _displayEndDate));
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TravelDetailTopBar(
              title: '여행 날짜 수정하기',
              onBackTap: _handleBack,
            ),
            const SizedBox(height: _kTopBarToTravelDateGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: AppTravelDate(
                startDate: _displayStartDate,
                endDate: _displayEndDate,
                showTitle: false,
              ),
            ),
            const SizedBox(height: _kTravelDateToCalendarGap),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) => AppCalendar(
                      width: constraints.maxWidth,
                      initialMonth: _displayStartDate,
                      onRangeSelected: _handleRangeSelected,
                      onSelectionCleared: _handleSelectionCleared,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _kHorizontalPadding,
                0,
                _kHorizontalPadding,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '저장',
                isEnabled: _canSave,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TravelDateEditScreen _previewScreen() {
  return TravelDateEditScreen(
    initialStartDate: DateTime(2026, 8, 18),
    initialEndDate: DateTime(2026, 8, 21),
  );
}

@Preview(
  group: 'travel_settings',
  name: 'TravelDateEditScreen',
  size: Size(390, 844),
)
Widget travelDateEditScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _previewScreen(),
  );
}
