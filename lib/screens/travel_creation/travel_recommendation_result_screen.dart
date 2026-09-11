import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_recommendation_model.dart';
import '../../data/repositories/tourist_spot/tourist_spot_repository.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../course_edit/course_edit_screen.dart';
import '../explore/travel_creation_explore_page.dart';
import '../travel_detail/travel_detail_page.dart';
import '../travel_detail/public_travel_detail_page.dart';
import 'travel_creation_data.dart';
import 'widgets/travel_creation_header.dart';
import 'pozit_pick_detail_screen.dart';

class TravelRecommendationResultScreen extends StatelessWidget {
  const TravelRecommendationResultScreen({
    super.key,
    required this.travelInfo,
    this.onBackTap,
    this.onBrowseOtherCourses,
    required this.recommendationCard,
    required this.recommendation,
    this.repository = const TravelRepository(),
  });

  final TravelInfoResult travelInfo;
  final VoidCallback? onBackTap;
  final VoidCallback? onBrowseOtherCourses;
  final TravelRecommendationCardModel recommendationCard;
  final TravelRecommendationModel recommendation;
  final TravelRepository repository;

  @override
  Widget build(BuildContext context) {
    return _ApiRecommendationResult(
      travelInfo: travelInfo,
      recommendationCard: recommendationCard,
      recommendation: recommendation,
      repository: repository,
      onBackTap: onBackTap,
      onBrowseOtherCourses: onBrowseOtherCourses,
    );
  }
}

class _ApiRecommendationResult extends StatefulWidget {
  const _ApiRecommendationResult({
    required this.travelInfo,
    required this.recommendationCard,
    required this.recommendation,
    required this.repository,
    this.onBackTap,
    this.onBrowseOtherCourses,
  });

  final TravelInfoResult travelInfo;
  final TravelRecommendationCardModel recommendationCard;
  final TravelRecommendationModel recommendation;
  final TravelRepository repository;
  final VoidCallback? onBackTap;
  final VoidCallback? onBrowseOtherCourses;

  @override
  State<_ApiRecommendationResult> createState() =>
      _ApiRecommendationResultState();
}

class _ApiRecommendationResultState extends State<_ApiRecommendationResult> {
  bool _isSaving = false;

  List<TravelCourseModel> get _courses =>
      widget.recommendation.toPreviewCourses();

  Future<void> _startEditing() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    int? draftTravelId;
    var completed = false;
    try {
      final created = await widget.repository.startRecommendedTravel(
        widget.recommendationCard.previewId,
        widget.recommendation,
      );
      draftTravelId = created.travelId;
      if (created.courses.isEmpty) {
        throw const ApiException('편집할 추천 코스 정보를 받지 못했어요.');
      }
      final courses = await Future.wait([
        for (final course in created.courses)
          widget.repository.getCourseDetail(course.courseId),
      ]);
      if (!mounted) {
        await widget.repository.cancelRecommendedTravel(created.travelId);
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CourseEditScreen(
            courses: courses,
            isCreationFlow: true,
            onLoadPopularSpots: (cursor) =>
                const TouristSpotRepository().getHostTouristSpotsRank(
                  regionCode: widget.travelInfo.regionCode,
                  cursor: cursor,
                ),
            onSearch: (keyword, cursor) => const TouristSpotRepository()
                .searchCourseSpots(keyword: keyword, cursor: cursor),
            onAddSelectedSpots: const TouristSpotRepository().saveSelectedSpots,
            onSave: (spotsByCourseId) async {
              await Future.wait([
                for (final entry in spotsByCourseId.entries)
                  widget.repository.updateCourseSpots(
                    entry.key,
                    entry.value.map((spot) => spot.touristSpotId).toList(),
                  ),
              ]);
              await widget.repository.completeRecommendedTravel(
                created.travelId,
              );
              completed = true;
              if (!mounted) return;
              await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => TravelDetailPage(travelId: created.travelId),
                ),
                (route) => route.isFirst,
              );
            },
          ),
        ),
      );
      if (!completed) {
        await widget.repository.cancelRecommendedTravel(created.travelId);
      }
    } on ApiException catch (error) {
      if (draftTravelId != null && !completed) {
        try {
          await widget.repository.cancelRecommendedTravel(draftTravelId);
        } catch (_) {}
      }
      if (mounted) showAppToast(context, error.message);
    } catch (_) {
      if (draftTravelId != null && !completed) {
        try {
          await widget.repository.cancelRecommendedTravel(draftTravelId);
        } catch (_) {}
      }
      if (mounted) showAppToast(context, '추천 여행을 시작하지 못했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openPreview() {
    final card = widget.recommendationCard;
    final places = widget.recommendation.days
        .expand((day) => day.places)
        .toList();
    final imageUrl = places.isEmpty ? '' : places.first.imageUrl;
    final imageUri = Uri.tryParse(imageUrl);
    final image =
        imageUri != null &&
            (imageUri.scheme == 'http' || imageUri.scheme == 'https')
        ? NetworkImage(imageUrl) as ImageProvider<Object>
        : const AssetImage(AppImages.travelMockup);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PozitPickDetailScreen(
          courses: _courses,
          startDate: card.startDate,
          endDate: card.endDate,
          destination: card.destination,
          title: card.cardTitle.isEmpty ? card.travelTitle : card.cardTitle,
          tags: card.tags,
          backgroundImage: image,
          onFollowCourseTap: _startEditing,
        ),
      ),
    );
  }

  void _handleBack() {
    final callback = widget.onBackTap;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _browseOtherCourses() {
    final callback = widget.onBrowseOtherCourses;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TravelCreationExplorePage(),
      ),
    );
  }

  void _openRelatedTravel(int travelId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicTravelDetailPage(travelId: travelId),
      ),
    );
  }

  ImageProvider<Object> _imageProvider(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https')
        ? NetworkImage(url)
        : const AssetImage(AppImages.travelMockup);
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.travelInfo.dateRange;
    final card = widget.recommendationCard;
    final previewImage = _imageProvider(card.thumbnailImageUrl);
    final dateText =
        '${range.start.month}/${range.start.day} ~ '
        '${range.end.month}/${range.end.day}';
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelCreationHeader(currentStepIndex: 1, onBackTap: _handleBack),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신의 여행 취향을 담아\nPozit이 추천 코스를 준비했어요.',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        height: 1.5,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTravelCard(
                      type: AppTravelCardType.pozitPick,
                      title: card.cardTitle.isEmpty
                          ? card.travelTitle
                          : card.cardTitle,
                      location: card.destination,
                      dateText: card.periodText.isEmpty
                          ? dateText
                          : card.periodText,
                      tags: card.tags,
                      author: 'Pozit',
                      backgroundImage: previewImage,
                      onTap: _openPreview,
                    ),
                    for (final related in card.relatedPublicTravels) ...[
                      const SizedBox(height: 8),
                      AppTravelCard(
                        type: AppTravelCardType.otherTravel,
                        title: related.title,
                        location: related.destination,
                        dateText:
                            '${related.startDate.month}/${related.startDate.day} ~ '
                            '${related.endDate.month}/${related.endDate.day}',
                        tags: related.tags,
                        author: related.leaderNickname,
                        participantCount: related.memberCount,
                        favoriteCount: related.likeCount,
                        isFavorite: related.isLiked,
                        backgroundImage: _imageProvider(
                          related.backgroundImageUrl,
                        ),
                        onTap: () => _openRelatedTravel(related.travelId),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _browseOtherCourses,
                        child: Text(
                          '다른 사람 코스 둘러보기',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray5,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.gray5,
                          ),
                        ),
                      ),
                    ),
                    if (_isSaving) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
