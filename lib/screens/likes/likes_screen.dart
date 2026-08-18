import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/like/liked_travel_model.dart';
import '../../data/repositories/like/like_repository.dart';
import '../travel_detail/public_travel_detail_page.dart';
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
    var currentFavorite = travel.isLiked;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PublicTravelDetailPage(
          travelId: travelId,
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

@Preview(group: 'haerim', name: '찜 화면', size: Size(393, 852))
Widget likesScreenPreview() =>
    MaterialApp(home: LikesScreen(initialTravels: likesPreviewTravels()));
