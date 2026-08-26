import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/like/liked_travel_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../../data/repositories/travel/public_travel_repository.dart';
import '../travel_detail/public_travel_detail_page.dart';
import 'explore_content.dart';
import 'explore_screen.dart';

class TravelCreationExplorePage extends StatefulWidget {
  const TravelCreationExplorePage({
    super.key,
    this.repository = const PublicTravelRepository(),
    this.likeRepository = const LikeRepository(),
  });

  final PublicTravelRepository repository;
  final LikeRepository likeRepository;

  @override
  State<TravelCreationExplorePage> createState() =>
      _TravelCreationExplorePageState();
}

class _TravelCreationExplorePageState extends State<TravelCreationExplorePage> {
  List<LikedTravelModel>? _travels;
  Set<int> _likedTravelIds = const <int>{};
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final results = await Future.wait([
        widget.repository.getPopularTravelCards(),
        widget.likeRepository.getLikes(),
      ]);
      final travels = results[0];
      final likedTravels = results[1];
      if (!mounted) return;
      setState(() {
        _travels = travels;
        _likedTravelIds = likedTravels.map((travel) => travel.travelId).toSet();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _openTravel(int travelId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicTravelDetailPage(
          travelId: travelId,
          likeRepository: widget.likeRepository,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _toggleFavorite(int travelId, bool isFavorite) async {
    if (isFavorite) {
      await widget.likeRepository.likeTravel(travelId);
    } else {
      await widget.likeRepository.unlikeTravel(travelId);
    }
    if (!mounted) return;
    setState(() {
      if (isFavorite) {
        _likedTravelIds.add(travelId);
      } else {
        _likedTravelIds.remove(travelId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _StatusScaffold(
        child: AppRetryErrorView(
          message: error is ApiException
              ? error.message
              : '공개 여행 목록을 불러오지 못했습니다.',
          onRetry: _load,
          retrySemanticLabel: '공개 여행 목록 다시 불러오기',
        ),
      );
    }
    final travels = _travels;
    if (travels == null) {
      return const _StatusScaffold(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.purple3),
        ),
      );
    }
    return ExploreScreen(
      isTravelCreationMode: true,
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

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppDetailHeader(
              title: '탐색',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
