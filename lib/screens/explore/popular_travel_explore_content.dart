import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/like/liked_travel_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../../data/repositories/travel/public_travel_repository.dart';
import '../travel_detail/public_travel_detail_page.dart';
import 'explore_content.dart';

class PopularTravelExploreContent extends StatefulWidget {
  const PopularTravelExploreContent({
    super.key,
    this.repository = const PublicTravelRepository(),
    this.likeRepository = const LikeRepository(),
  });

  final PublicTravelRepository repository;
  final LikeRepository likeRepository;

  @override
  State<PopularTravelExploreContent> createState() =>
      _PopularTravelExploreContentState();
}

class _PopularTravelExploreContentState
    extends State<PopularTravelExploreContent> {
  List<LikedTravelModel>? _travels;
  Set<int> _likedTravelIds = const {};
  Object? _error;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    setState(() => _error = null);
    try {
      final results = await Future.wait([
        widget.repository.getPopularTravelCards(),
        widget.likeRepository.getLikes(),
      ]);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _travels = results[0];
        _likedTravelIds = results[1].map((travel) => travel.travelId).toSet();
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _error = error);
    }
  }

  Future<void> _openTravel(int travelId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicTravelDetailPage(
          travelId: travelId,
          initialIsFavorite: _likedTravelIds.contains(travelId),
          repository: widget.repository,
          likeRepository: widget.likeRepository,
          onFavoriteChanged: (isFavorite) =>
              _applyFavoriteState(travelId, isFavorite),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _toggleFavorite(int travelId, bool isFavorite) async {
    _applyFavoriteState(travelId, isFavorite);
    try {
      if (isFavorite) {
        await widget.likeRepository.likeTravel(travelId);
      } else {
        await widget.likeRepository.unlikeTravel(travelId);
      }
    } catch (_) {
      if (mounted) _applyFavoriteState(travelId, !isFavorite);
      rethrow;
    }
  }

  void _applyFavoriteState(int travelId, bool isFavorite) {
    if (!mounted) return;
    final wasFavorite = _likedTravelIds.contains(travelId);
    setState(() {
      isFavorite
          ? _likedTravelIds.add(travelId)
          : _likedTravelIds.remove(travelId);
      _travels = _travels?.map((travel) {
        if (travel.travelId != travelId) return travel;
        final nextLikeCount = wasFavorite == isFavorite
            ? travel.likeCount
            : isFavorite
            ? travel.likeCount + 1
            : travel.likeCount > 0
            ? travel.likeCount - 1
            : 0;
        return travel.copyWith(likeCount: nextLikeCount, isLiked: isFavorite);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return AppRetryErrorView(
        message: error is ApiException ? error.message : '인기 여행을 불러오지 못했습니다.',
        onRetry: _load,
        retrySemanticLabel: '인기 여행 다시 불러오기',
      );
    }
    final travels = _travels;
    if (travels == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return ExploreContent(
      travels: travels.map(_toExploreItem).toList(),
      onTravelTap: _openTravel,
      onFavoriteToggle: _toggleFavorite,
    );
  }

  ExploreTravelItem _toExploreItem(LikedTravelModel travel) {
    return ExploreTravelItem(
      id: travel.travelId,
      title: travel.title,
      location: travel.destination,
      dateText:
          '${travel.startDate.month}/${travel.startDate.day} ~ '
          '${travel.endDate.month}/${travel.endDate.day}',
      author: travel.leaderNickname,
      participantCount: travel.memberCount,
      tags: travel.tags,
      region: travel.destination,
      startDate: travel.startDate,
      endDate: travel.endDate,
      favoriteCount: travel.likeCount,
      isFavorite: _likedTravelIds.contains(travel.travelId),
      backgroundImageUrl: travel.backgroundImageUrl,
    );
  }
}
