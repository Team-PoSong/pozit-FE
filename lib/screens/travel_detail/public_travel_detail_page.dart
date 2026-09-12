import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel/public_travel_detail_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../../data/repositories/travel/public_travel_repository.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../travel_creation/travel_creation_data.dart';
import '../travel_creation/travel_schedule_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import 'travel_detail_screen.dart';

const double _kTopOffset = 4.0;

enum _PublicDetailLoadStatus { loading, error, loaded }

class PublicTravelDetailPage extends StatefulWidget {
  const PublicTravelDetailPage({
    super.key,
    required this.travelId,
    this.initialIsFavorite,
    this.onFavoriteChanged,
    this.onFollowCourseTap,
    PublicTravelRepository? repository,
    LikeRepository? likeRepository,
    TravelRepository? travelRepository,
  }) : repository = repository ?? const PublicTravelRepository(),
       likeRepository = likeRepository ?? const LikeRepository(),
       travelRepository = travelRepository ?? const TravelRepository();

  final int travelId;
  final bool? initialIsFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onFollowCourseTap;
  final PublicTravelRepository repository;
  final LikeRepository likeRepository;
  final TravelRepository travelRepository;

  @override
  State<PublicTravelDetailPage> createState() => _PublicTravelDetailPageState();
}

class _PublicTravelDetailPageState extends State<PublicTravelDetailPage> {
  _PublicDetailLoadStatus _status = _PublicDetailLoadStatus.loading;
  PublicTravelDetailModel? _detail;
  String _errorMessage = '';
  bool _isOpeningDraft = false;
  bool _isOpeningCourseMap = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_status != _PublicDetailLoadStatus.loading) {
      setState(() => _status = _PublicDetailLoadStatus.loading);
    }
    try {
      final detail = await widget.repository.getTravelDetail(widget.travelId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _status = _PublicDetailLoadStatus.loaded;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _status = _PublicDetailLoadStatus.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '공개 여행 정보를 불러오지 못했습니다.';
        _status = _PublicDetailLoadStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _PublicDetailLoadStatus.loading => Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: _kTopOffset),
            child: Column(
              children: [
                AppDetailHeader(
                  title: '여행 상세',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _PublicDetailLoadStatus.error => _buildError(),
      _PublicDetailLoadStatus.loaded => _buildDetail(_detail!),
    };
  }

  Widget _buildDetail(PublicTravelDetailModel detail) {
    return Stack(
      children: [
        TravelDetailScreen(
          title: detail.title,
          info: TravelInfoCardModel(
            destination: detail.destination,
            startDate: detail.startDate,
            endDate: detail.endDate,
            companionCount: detail.memberCount,
            tags: detail.tags,
            visitedPlaceCount: _visitedPlaceCount(detail),
            recordCount: detail.totalPozingCount,
            completionRate: (detail.completionRate / 100.0)
                .clamp(0.0, 1.0)
                .toDouble(),
          ),
          status: detail.status,
          isLeader: false,
          isPublic: true,
          isMyTravel: false,
          authorName: detail.leaderNickname,
          isFavorite: widget.initialIsFavorite ?? detail.isLiked,
          courses: detail.courses,
          members: detail.members,
          backgroundImage: _backgroundImage(detail.backgroundImageUrl),
          onBackTap: () => Navigator.of(context).maybePop(),
          onFavoriteToggle: (isFavorite) => isFavorite
              ? widget.likeRepository.likeTravel(detail.travelId)
              : widget.likeRepository.unlikeTravel(detail.travelId),
          onFavoriteChanged: widget.onFavoriteChanged,
          onCourseTap: (day) => _openCourseMap(detail, day),
          onFollowCourseTap:
              widget.onFollowCourseTap ?? () => _followCourse(detail),
        ),
        if (_isOpeningCourseMap)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openCourseMap(PublicTravelDetailModel detail, int day) async {
    if (_isOpeningCourseMap) return;
    setState(() => _isOpeningCourseMap = true);
    try {
      final courses = await Future.wait(
        detail.courses.map((course) async {
          try {
            return await widget.repository.getCourseDetail(course.courseId);
          } catch (_) {
            return course;
          }
        }),
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => TravelCourseMapScreen(
            courses: courses,
            status: detail.status,
            totalDays: detail.endDate.difference(detail.startDate).inDays + 1,
            initialDay: day,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isOpeningCourseMap = false);
    }
  }

  Future<void> _followCourse(PublicTravelDetailModel detail) async {
    if (_isOpeningDraft) return;
    setState(() => _isOpeningDraft = true);
    try {
      final draft = await widget.travelRepository.getLikeBasedTravelDraft(
        detail.travelId,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TravelScheduleScreen(
            destination: draft.destination,
            regionCode: draft.regionCode,
            creationMethod: TravelCreationMethod.wish,
            initialCourses: detail.courses,
            initialTags: detail.tags,
            initialTagIds: draft.tagIds,
            sourceTravelId: draft.sourceTravelId,
            backgroundImageUrl: draft.backgroundImageUrl,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppToast(context, error.message);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, '찜 기반 여행 초안을 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _isOpeningDraft = false);
    }
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: _kTopOffset),
          child: Column(
            children: [
              AppDetailHeader(
                title: '여행 상세',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: AppRetryErrorView(
                  message: _errorMessage,
                  onRetry: _load,
                  retrySemanticLabel: '공개 여행 다시 불러오기',
                  isRetryUnderlined: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _visitedPlaceCount(PublicTravelDetailModel detail) {
  return detail.courses
      .expand((course) => course.spots)
      .where((spot) => spot.status == 'visited')
      .length;
}

ImageProvider<Object>? _backgroundImage(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
    return NetworkImage(url);
  }
  return null;
}
