import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel/travel_recommendation_model.dart';
import '../../data/repositories/travel/travel_repository.dart';
import 'travel_creation_pipeline.dart';
import 'travel_creation_data.dart';
import 'travel_recommendation_result_screen.dart';
import 'widgets/travel_creation_header.dart';

class TravelRecommendationLoadResult {
  const TravelRecommendationLoadResult({
    required this.card,
    required this.recommendation,
  });

  final TravelRecommendationCardModel card;
  final TravelRecommendationModel recommendation;
}

class TravelRecommendationLoadingScreen extends StatefulWidget {
  const TravelRecommendationLoadingScreen({
    super.key,
    required this.travelInfo,
    this.loadRecommendations,
    this.onBackTap,
    this.repository = const TravelRepository(),
  });

  final TravelInfoResult travelInfo;
  final Future<TravelRecommendationLoadResult> Function()? loadRecommendations;
  final VoidCallback? onBackTap;
  final TravelRepository repository;

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
  String? _loadErrorMessage;
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
    setState(() {
      _hasLoadError = false;
      _loadErrorMessage = null;
    });
    try {
      TravelRecommendationCardModel? recommendationCard;
      TravelRecommendationModel? recommendation;
      final callback = widget.loadRecommendations;
      if (callback != null) {
        final result = await callback();
        recommendationCard = result.card;
        recommendation = result.recommendation;
      } else if (_usesApi) {
        recommendationCard = await widget.repository.previewRecommendationCard(
          TravelCreationPipeline.buildCreateRequest(widget.travelInfo),
        );
        recommendation = await widget.repository.getRecommendationPreview(
          recommendationCard.previewId,
        );
      }
      if (recommendationCard == null || recommendation == null) {
        throw const ApiException('추천 코스 응답을 받지 못했어요.');
      }
      final resultCard = recommendationCard;
      final resultRecommendation = recommendation;
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TravelRecommendationResultScreen(
            travelInfo: widget.travelInfo,
            recommendationCard: resultCard,
            recommendation: resultRecommendation,
            repository: widget.repository,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasLoadError = true;
          _loadErrorMessage = error is ApiException
              ? error.message
              : '추천 코스를 불러오지 못했어요.';
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  bool get _usesApi =>
      widget.travelInfo.regionCode != null &&
      widget.travelInfo.tagIds.isNotEmpty;

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final onBackTap = widget.onBackTap;
    if (onBackTap != null) {
      onBackTap();
      return;
    }
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
            TravelCreationHeader(currentStepIndex: 1, onBackTap: _handleBack),
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
                              _loadErrorMessage ?? '추천 코스를 불러오지 못했어요.',
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
