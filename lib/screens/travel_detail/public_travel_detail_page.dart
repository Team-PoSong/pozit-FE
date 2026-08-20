import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel/public_travel_detail_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../../data/repositories/travel/public_travel_repository.dart';
import '../travel_creation/travel_creation_data.dart';
import '../travel_creation/travel_schedule_screen.dart';
import 'travel_detail_screen.dart';

const double _kTopOffset = 4.0;

enum _PublicDetailLoadStatus { loading, error, loaded }

class PublicTravelDetailPage extends StatefulWidget {
  const PublicTravelDetailPage({
    super.key,
    required this.travelId,
    this.onFavoriteChanged,
    this.onFollowCourseTap,
    PublicTravelRepository? repository,
    LikeRepository? likeRepository,
  }) : repository = repository ?? const PublicTravelRepository(),
       likeRepository = likeRepository ?? const LikeRepository();

  final int travelId;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onFollowCourseTap;
  final PublicTravelRepository repository;
  final LikeRepository likeRepository;

  @override
  State<PublicTravelDetailPage> createState() => _PublicTravelDetailPageState();
}

class _PublicTravelDetailPageState extends State<PublicTravelDetailPage> {
  _PublicDetailLoadStatus _status = _PublicDetailLoadStatus.loading;
  PublicTravelDetailModel? _detail;
  String _errorMessage = '';

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
                    child: CircularProgressIndicator(color: AppColors.purple3),
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
    return TravelDetailScreen(
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
      isFavorite: detail.isLiked,
      courses: detail.courses,
      members: detail.members,
      backgroundImage: _backgroundImage(detail.backgroundImageUrl),
      onBackTap: () => Navigator.of(context).maybePop(),
      onFavoriteToggle: (isFavorite) => isFavorite
          ? widget.likeRepository.likeTravel(detail.travelId)
          : widget.likeRepository.unlikeTravel(detail.travelId),
      onFavoriteChanged: widget.onFavoriteChanged,
      onFollowCourseTap:
          widget.onFollowCourseTap ?? () => _followCourse(detail),
    );
  }

  void _followCourse(PublicTravelDetailModel detail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelScheduleScreen(
          destination: detail.destination,
          creationMethod: TravelCreationMethod.wish,
          initialCourses: detail.courses,
          initialTags: detail.tags,
        ),
      ),
    );
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

ImageProvider<Object> _backgroundImage(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
    return NetworkImage(url);
  }
  return const AssetImage(AppImages.travelMockup);
}
