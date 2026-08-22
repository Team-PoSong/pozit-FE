import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../data/models/saved_travel_model.dart';
import '../../data/mock/mock_travel_courses.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/models/travel/travel_recommendation_model.dart';
import '../../data/repositories/local/travel_store.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../course_edit/course_edit_screen.dart';
import '../explore/explore_content.dart';
import '../explore/explore_screen.dart';
import '../explore/travel_creation_explore_page.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import '../travel_detail/travel_detail_screen.dart';
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
    this.onRecommendationTap,
    this.travelId,
    this.recommendationCard,
    this.recommendation,
    this.repository = const TravelRepository(),
  });

  final TravelInfoResult travelInfo;
  final VoidCallback? onBackTap;
  final VoidCallback? onBrowseOtherCourses;
  final VoidCallback? onRecommendationTap;
  final int? travelId;
  final TravelRecommendationCardModel? recommendationCard;
  final TravelRecommendationModel? recommendation;
  final TravelRepository repository;

  void _handleBack(BuildContext context) {
    final callback = onBackTap;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _openPozitPick(BuildContext context) {
    onRecommendationTap?.call();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PozitPickDetailScreen()),
    );
  }

  void _browseOtherCourses(BuildContext context) {
    final callback = onBrowseOtherCourses;
    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExploreScreen(
          isTravelCreationMode: true,
          travels: explorePreviewTravels,
        ),
      ),
    );
  }

  void _openTravelDetail(
    BuildContext context, {
    required String destination,
    required List<String> tags,
    required String authorName,
  }) {
    final courses = _mockCourses(destination);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelDetailScreen(
          title: '$destination 여행',
          info: TravelInfoCardModel(
            destination: destination,
            startDate: DateTime(2026, 7, 2),
            endDate: DateTime(2026, 7, 3),
            companionCount: 2,
            tags: tags,
            visitedPlaceCount: 12,
            recordCount: 48,
            completionRate: 0.67,
          ),
          status: AppTravelStatus.completed,
          isLeader: false,
          isMyTravel: false,
          authorName: authorName,
          courses: courses,
          onCourseTap: (_) => _openCourseMap(context, courses),
          onFollowCourseTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CourseEditScreen(
                courses: courses,
                isCreationFlow: true,
                onSave: (spotsByDay) => _saveFollowedCourse(
                  context,
                  destination: destination,
                  tags: tags,
                  courses: courses,
                  spotsByDay: spotsByDay,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveFollowedCourse(
    BuildContext context, {
    required String destination,
    required List<String> tags,
    required List<TravelCourseModel> courses,
    required Map<int, List<CourseSpotModel>> spotsByDay,
  }) {
    final info = TravelInfoCardModel(
      destination: destination,
      startDate: DateTime(2026, 7, 2),
      endDate: DateTime(2026, 7, 3),
      companionCount: 1,
      tags: tags,
      visitedPlaceCount: 0,
      recordCount: 0,
      completionRate: 0,
    );
    final savedCourses = [
      for (final course in courses)
        TravelCourseModel(
          courseId: course.courseId,
          dayNumber: course.dayNumber,
          date: course.date,
          spots: spotsByDay[course.dayNumber] ?? course.spots,
        ),
    ];

    TravelStore.instance.save(
      SavedTravelModel(
        id: 'followed-${destination.hashCode}',
        title: '$destination 여행',
        location: destination,
        dateText: info.dateRangeText,
        author: '나',
        info: info,
        courses: savedCourses,
        status: AppTravelStatus.upcoming,
        tags: tags,
        participantCount: 1,
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openCourseMap(BuildContext context, List<TravelCourseModel> courses) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelCourseMapScreen(
          courses: courses,
          status: AppTravelStatus.completed,
          totalDays: courses.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiRecommendation = recommendation;
    final apiRecommendationCard = recommendationCard;
    final apiTravelId = travelId;
    if (apiRecommendation != null &&
        apiRecommendationCard != null &&
        apiTravelId != null) {
      return _ApiRecommendationResult(
        travelInfo: travelInfo,
        travelId: apiTravelId,
        recommendationCard: apiRecommendationCard,
        recommendation: apiRecommendation,
        repository: repository,
        onBackTap: onBackTap,
        onBrowseOtherCourses: onBrowseOtherCourses,
      );
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelCreationHeader(
              currentStepIndex: 1,
              onBackTap: () => _handleBack(context),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
                      title: '6월 추천, 강릉은 어때요?',
                      location: '강원 강릉',
                      dateText: '1박 2일',
                      tags: const ['문화', '탐험'],
                      author: '포송',
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openPozitPick(context),
                    ),
                    const SizedBox(height: 8),
                    AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '경주 여행',
                      location: '경북 경주',
                      dateText: '7/2 ~ 7/3',
                      tags: const ['힐링', '미식'],
                      author: '해림',
                      participantCount: 2,
                      favoriteCount: 14,
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openTravelDetail(
                        context,
                        destination: '경주',
                        tags: const ['힐링', '미식'],
                        authorName: '해림',
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTravelCard(
                      type: AppTravelCardType.otherTravel,
                      title: '강릉 데이트',
                      location: '강원 강릉',
                      dateText: '7/2 ~ 7/3',
                      tags: const ['문화', '탐험'],
                      author: '민서',
                      participantCount: 2,
                      favoriteCount: 12,
                      backgroundImage: const AssetImage(AppImages.travelMockup),
                      onTap: () => _openTravelDetail(
                        context,
                        destination: '강릉',
                        tags: const ['문화', '탐험'],
                        authorName: '민서',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _browseOtherCourses(context),
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

class _ApiRecommendationResult extends StatefulWidget {
  const _ApiRecommendationResult({
    required this.travelInfo,
    required this.travelId,
    required this.recommendationCard,
    required this.recommendation,
    required this.repository,
    this.onBackTap,
    this.onBrowseOtherCourses,
  });

  final TravelInfoResult travelInfo;
  final int travelId;
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

  Future<void> _commit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.repository.commitRecommendations(
        widget.travelId,
        widget.recommendation,
      );
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => TravelDetailPage(travelId: widget.travelId),
        ),
        (route) => route.isFirst,
      );
    } catch (_) {
      rethrow;
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
          onFollowCourseTap: _commit,
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
                      const Center(child: CircularProgressIndicator()),
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

List<TravelCourseModel> _mockCourses(String destination) {
  final names = destination == '경주'
      ? const ['불국사', '동궁과 월지', '첨성대', '대릉원']
      : const ['경포생태습지공원', '초당순두부', '강문 해변', '정동진 해변'];
  final baseLatitude = destination == '경주' ? 35.80 : 37.75;
  final baseLongitude = destination == '경주' ? 129.20 : 128.90;
  return buildMockTravelCourses(
    startDate: DateTime(2026, 7, 2),
    dayCount: 2,
    spotsPerDay: 2,
    firstSpotVisited: true,
    spots: [
      for (var index = 0; index < names.length; index++)
        MockCourseSpot(
          name: names[index],
          address: destination == '경주' ? '경북 경주시' : '강원특별자치도 강릉시',
          latitude: baseLatitude + (index ~/ 2) * 0.01 + (index % 2) * 0.005,
          longitude: baseLongitude + (index ~/ 2) * 0.01 + (index % 2) * 0.005,
        ),
    ],
  );
}
