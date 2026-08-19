import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/progress/app_density_track.dart';
import 'travel_creation_data.dart';
import 'travel_recommendation_loading_screen.dart';
import 'widgets/travel_creation_header.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({
    super.key,
    required this.travelInfo,
    this.onNext,
    this.onBackTap,
  });

  final TravelInfoResult travelInfo;
  final ValueChanged<TravelInfoResult>? onNext;
  final VoidCallback? onBackTap;

  @override
  State<TravelPreferencesScreen> createState() =>
      _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  static const List<String> _transportationOptions = [
    '도보',
    '자전거',
    '대중교통',
    '자동차',
  ];

  String? _transportation;
  int? _densityLevel = 1;

  bool get _canContinue => _transportation != null && _densityLevel != null;

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
    final result = widget.travelInfo.copyWith(
      transportation: _transportation,
      densityLevel: _densityLevel,
    );
    final onNext = widget.onNext;
    if (onNext != null) {
      onNext(result);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelRecommendationLoadingScreen(travelInfo: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelCreationHeader(currentStepIndex: 1, onBackTap: _handleBack),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '여행을 시작해볼까요?',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '여행 정보를 입력하고\nPozit과 함께 여행을 시작해보세요.',
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '이동 수단을 알려주세요.',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        for (
                          var index = 0;
                          index < _transportationOptions.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(width: 9),
                          Expanded(
                            child: AppTagChip(
                              label: _transportationOptions[index],
                              isSelected:
                                  _transportation ==
                                  _transportationOptions[index],
                              onTap: () => setState(
                                () => _transportation =
                                    _transportationOptions[index],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '어떤 스타일의 여행인가요?',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: AppDensityTrack(
                        selectedIndex: _densityLevel,
                        onLevelSelected: (level) =>
                            setState(() => _densityLevel = level),
                      ),
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

@Preview(group: 'hycho', name: 'Travel Preferences', size: Size(393, 852))
Widget travelPreferencesScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelPreferencesScreen(
      travelInfo: TravelInfoResult(
        destination: '경주',
        dateRange: DateTimeRange(
          start: DateTime(2026, 7, 3),
          end: DateTime(2026, 7, 6),
        ),
        name: '포송한 여행',
        tags: const {'미식'},
        creationMethod: TravelCreationMethod.recommendation,
      ),
    ),
  );
}
