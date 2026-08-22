import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/like/liked_travel_model.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/mock/mock_travel_courses.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../travel_detail/public_travel_detail_page.dart';
import '../travel_detail/travel_detail_screen.dart';
import '../travel_creation/travel_creation_data.dart';
import '../travel_creation/travel_schedule_screen.dart';
import 'likes_content.dart';

const double _kTopOffset = 4.0;

class LikesScreen extends StatefulWidget {
  const LikesScreen({
    super.key,
    this.initialTravels,
    this.onBackTap,
    this.onTravelTap,
    this.onFavoriteTap,
    this.onFollowCourseTap,
    LikeRepository? repository,
  }) : repository = repository ?? const LikeRepository();

  final List<LikedTravelModel>? initialTravels;
  final VoidCallback? onBackTap;
  final ValueChanged<int>? onTravelTap;
  final Future<void> Function(int travelId)? onFavoriteTap;
  final ValueChanged<int>? onFollowCourseTap;
  final LikeRepository repository;

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  List<LikedTravelModel>? _travels;
  Object? _error;
  final Set<int> _pendingTravelIds = {};
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _travels = widget.initialTravels == null
        ? null
        : List.of(widget.initialTravels!);
    if (_travels == null) _loadLikes();
  }

  @override
  void didUpdateWidget(covariant LikesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.initialTravels, widget.initialTravels)) return;

    _loadGeneration++;
    _error = null;
    if (widget.initialTravels case final travels?) {
      _travels = List.of(travels);
      return;
    }

    _travels = null;
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final generation = ++_loadGeneration;
    setState(() => _error = null);
    try {
      final travels = await widget.repository.getLikes();
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _travels = travels);
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _error = error);
    }
  }

  Future<void> _handleFavoriteTap(int travelId) async {
    if (_pendingTravelIds.contains(travelId)) return;
    setState(() => _pendingTravelIds.add(travelId));

    try {
      if (widget.onFavoriteTap case final callback?) {
        await callback(travelId);
      } else {
        await widget.repository.unlikeTravel(travelId);
      }
      if (!mounted) return;
      _removeTravelLocally(travelId);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException ? error.message : '찜을 해제하지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _pendingTravelIds.remove(travelId));
    }
  }

  void _handleBack() {
    if (widget.onBackTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleTravelTap(int travelId) async {
    if (widget.onTravelTap case final callback?) {
      callback(travelId);
      return;
    }

    final travels = _travels;
    if (travels == null) return;
    final travelIndex = travels.indexWhere((item) => item.travelId == travelId);
    if (travelIndex == -1) return;
    final travel = travels[travelIndex];
    if (widget.initialTravels != null) {
      await _openPreviewTravelDetail(travel);
      return;
    }
    var currentFavorite = travel.isLiked;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PublicTravelDetailPage(
          travelId: travelId,
          initialIsFavorite: travel.isLiked,
          likeRepository: widget.repository,
          onFavoriteChanged: (isFavorite) => currentFavorite = isFavorite,
          onFollowCourseTap: widget.onFollowCourseTap == null
              ? null
              : () => widget.onFollowCourseTap!(travelId),
        ),
      ),
    );
    if (!mounted || currentFavorite) return;
    _removeTravelLocally(travelId);
  }

  Future<void> _openPreviewTravelDetail(LikedTravelModel travel) {
    final courses = _previewCourses(travel);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TravelDetailScreen(
          title: travel.title,
          info: TravelInfoCardModel(
            destination: travel.destination,
            startDate: travel.startDate,
            endDate: travel.endDate,
            companionCount: travel.memberCount,
            tags: travel.tags,
            visitedPlaceCount: 0,
            recordCount: 0,
            completionRate: travel.completionRate / 100,
          ),
          status: travel.status,
          isLeader: false,
          isMyTravel: false,
          authorName: travel.leaderNickname,
          isFavorite: true,
          courses: courses,
          backgroundImage: const AssetImage(AppImages.travelMockup),
          onFavoriteToggle: (_) async {},
          onFollowCourseTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TravelScheduleScreen(
                destination: travel.destination,
                creationMethod: TravelCreationMethod.wish,
                initialCourses: courses,
                initialTags: travel.tags,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeTravelLocally(int travelId) {
    setState(() {
      _travels?.removeWhere((travel) => travel.travelId == travelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: _kTopOffset),
          child: Column(
            children: [
              AppDetailHeader(title: '찜', onBack: _handleBack),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error case final error?) {
      final message = error is ApiException
          ? error.message
          : '찜 목록을 불러오지 못했습니다.';
      return AppRetryErrorView(
        message: message,
        onRetry: _loadLikes,
        retrySemanticLabel: '찜 목록 다시 불러오기',
        isRetryUnderlined: true,
      );
    }
    if (_travels case final travels?) {
      return LikesContent(
        travels: travels,
        onTravelTap: _handleTravelTap,
        onFavoriteTap: _handleFavoriteTap,
        pendingFavoriteIds: _pendingTravelIds,
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple3),
    );
  }
}

List<TravelCourseModel> _previewCourses(LikedTravelModel travel) {
  final dayCount = travel.endDate.difference(travel.startDate).inDays + 1;
  return buildMockTravelCourses(
    startDate: travel.startDate,
    dayCount: dayCount.clamp(1, 4),
    repeatSpotsEachDay: true,
    spots: const [
      MockCourseSpot(
        name: '첨성대',
        address: '경북 경주시 인왕동 839-1',
        latitude: 35.8347,
        longitude: 129.2194,
      ),
      MockCourseSpot(
        name: '동궁과 월지',
        address: '경북 경주시 원화로 102',
        latitude: 35.8347,
        longitude: 129.2247,
      ),
      MockCourseSpot(
        name: '대릉원',
        address: '경북 경주시 계림로 9',
        latitude: 35.8351,
        longitude: 129.2118,
      ),
      MockCourseSpot(
        name: '황리단길',
        address: '경북 경주시 포석로 1080',
        latitude: 35.8370,
        longitude: 129.2090,
      ),
    ],
  );
}

@Preview(group: 'haerim', name: '찜 화면', size: Size(393, 852))
Widget likesScreenPreview() =>
    MaterialApp(home: LikesScreen(initialTravels: likesPreviewTravels()));
