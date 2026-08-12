import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_creation_data.dart';
import 'travel_recommendation_result_screen.dart';

class TravelRecommendationLoadingScreen extends StatefulWidget {
  const TravelRecommendationLoadingScreen({
    super.key,
    required this.travelInfo,
    this.loadRecommendations,
    this.onBackTap,
  });

  final TravelInfoResult travelInfo;
  final Future<void> Function()? loadRecommendations;
  final VoidCallback? onBackTap;

  @override
  State<TravelRecommendationLoadingScreen> createState() =>
      _TravelRecommendationLoadingScreenState();
}

class _TravelRecommendationLoadingScreenState
    extends State<TravelRecommendationLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatingController;
  late final Animation<double> _floatingOffset;
  bool _hasLoadError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _floatingOffset = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (_isLoading) return;
    _isLoading = true;
    setState(() => _hasLoadError = false);
    try {
      await (widget.loadRecommendations?.call() ??
          Future<void>.delayed(const Duration(seconds: 2)));
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              TravelRecommendationResultScreen(travelInfo: widget.travelInfo),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _hasLoadError = true);
    } finally {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 1),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '당신의 여행 취향을 담아\nPozit이 추천 코스를 준비중이에요..',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  height: 1.5,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: _hasLoadError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '추천 코스를 불러오지 못했어요.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.gray5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: '다시 시도하기',
                              onPressed: _loadRecommendations,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: AnimatedBuilder(
                        animation: _floatingOffset,
                        child: Image.asset(
                          AppImages.carrierTicket,
                          width: 126,
                          height: 193,
                          fit: BoxFit.contain,
                        ),
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _floatingOffset.value),
                          child: child,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
