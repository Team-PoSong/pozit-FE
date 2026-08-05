import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

class TravelInfoResult {
  const TravelInfoResult({
    required this.destination,
    required this.dateRange,
    required this.name,
    required this.tags,
  });

  final String destination;
  final DateTimeRange dateRange;
  final String name;
  final Set<String> tags;
}

class TravelInfoScreen extends StatefulWidget {
  const TravelInfoScreen({
    super.key,
    required this.destination,
    required this.dateRange,
    this.onSave,
    this.onBackTap,
  });

  final String destination;
  final DateTimeRange dateRange;
  final ValueChanged<TravelInfoResult>? onSave;
  final VoidCallback? onBackTap;

  @override
  State<TravelInfoScreen> createState() => _TravelInfoScreenState();
}

class _TravelInfoScreenState extends State<TravelInfoScreen> {
  static const int _maximumTagCount = 2;
  static const List<String> _tagOptions = [
    '기록',
    '미식',
    '힐링',
    '체험',
    '문화',
    '예술',
    '쇼핑',
    '탐험',
  ];

  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedTags = {};

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _selectedTags.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleTagTap(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < _maximumTagCount) {
        _selectedTags.add(tag);
      }
    });
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  void _handleSave() {
    if (!_canSave) return;
    widget.onSave?.call(
      TravelInfoResult(
        destination: widget.destination,
        dateRange: widget.dateRange,
        name: _nameController.text.trim(),
        tags: Set.unmodifiable(_selectedTags),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 1),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '어떤 여행인지 알려주세요.',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '여행명',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppInputField(
                      controller: _nameController,
                      hintText: '직접 입력',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '어떤 여행인가요?(최대 2개 선택)',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 9,
                      runSpacing: 10,
                      children: [
                        for (final tag in _tagOptions)
                          AppTagChip(
                            label: '# $tag',
                            isSelected: _selectedTags.contains(tag),
                            onTap: () => _handleTagTap(tag),
                          ),
                      ],
                    ),
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

@Preview(group: 'hycho', name: 'Travel Info', size: Size(393, 852))
Widget travelInfoScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelInfoScreen(
        destination: '경상북도 경주시',
        dateRange: DateTimeRange(
          start: DateTime(2026, 7, 3),
          end: DateTime(2026, 7, 5),
        ),
      ),
    ),
  );
}
