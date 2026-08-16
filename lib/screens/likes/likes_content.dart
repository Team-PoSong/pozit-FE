import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../data/models/like/liked_travel_model.dart';

const double _kHorizontalPadding = 24.0;
const double _kListTopPadding = 8.0;
const double _kListBottomPadding = 24.0;
const double _kCardGap = 8.0;

class LikesContent extends StatelessWidget {
  const LikesContent({
    super.key,
    required this.travels,
    this.onTravelTap,
    this.onFavoriteTap,
    this.pendingFavoriteIds = const {},
  });

  final List<LikedTravelModel> travels;
  final ValueChanged<int>? onTravelTap;
  final ValueChanged<int>? onFavoriteTap;
  final Set<int> pendingFavoriteIds;

  @override
  Widget build(BuildContext context) {
    if (travels.isEmpty) {
      return Center(
        child: Text(
          '찜한 여행이 없습니다.',
          style: AppTextStyles.body.copyWith(color: AppColors.gray5),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _kHorizontalPadding,
        _kListTopPadding,
        _kHorizontalPadding,
        _kListBottomPadding,
      ),
      itemCount: travels.length,
      separatorBuilder: (_, _) => const SizedBox(height: _kCardGap),
      itemBuilder: (context, index) {
        final travel = travels[index];
        return AppTravelCard(
          type: AppTravelCardType.otherTravel,
          title: travel.title,
          location: travel.destination,
          dateText: _dateText(travel.startDate, travel.endDate),
          tags: travel.tags,
          author: travel.leaderNickname,
          participantCount: travel.memberCount > 0 ? travel.memberCount - 1 : 0,
          backgroundImage: _networkImage(travel.backgroundImageUrl),
          isFavorite: travel.isLiked,
          favoriteCount: travel.likeCount,
          onTap: onTravelTap == null
              ? null
              : () => onTravelTap!(travel.travelId),
          onFavoriteTap: onFavoriteTap == null
              ? null
              : pendingFavoriteIds.contains(travel.travelId)
              ? _ignoreTap
              : () => onFavoriteTap!(travel.travelId),
        );
      },
    );
  }

  static String _dateText(DateTime startDate, DateTime endDate) {
    final totalDays = endDate.difference(startDate).inDays + 1;
    final duration = totalDays == 1 ? '당일치기' : '${totalDays - 1}박 $totalDays일';
    return '${startDate.month}/${startDate.day} ~ '
        '${endDate.month}/${endDate.day} · $duration';
  }
}

ImageProvider<Object>? _networkImage(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
    return null;
  }
  return NetworkImage(url);
}

List<LikedTravelModel> likesPreviewTravels() => [
  LikedTravelModel(
    travelId: 1,
    title: '경주 여행',
    destination: '경북 경주',
    startDate: DateTime(2026, 7, 2),
    endDate: DateTime(2026, 7, 3),
    tags: const ['힐링', '미식'],
    leaderNickname: '윤지',
    memberCount: 3,
    likeCount: 14,
    status: AppTravelStatus.completed,
    isPublic: true,
    backgroundImageUrl: '',
    completionRate: 67,
    isLiked: true,
  ),
  LikedTravelModel(
    travelId: 2,
    title: '서울 감성 여행',
    destination: '서울 종로',
    startDate: DateTime(2026, 7, 10),
    endDate: DateTime(2026, 7, 12),
    tags: const ['기록', '미식'],
    leaderNickname: '민서',
    memberCount: 4,
    likeCount: 21,
    status: AppTravelStatus.completed,
    isPublic: true,
    backgroundImageUrl: '',
    completionRate: 82,
    isLiked: true,
  ),
  LikedTravelModel(
    travelId: 3,
    title: '부산 바다 여행',
    destination: '부산 해운대',
    startDate: DateTime(2026, 8, 4),
    endDate: DateTime(2026, 8, 5),
    tags: const ['힐링', '체험'],
    leaderNickname: '해림',
    memberCount: 2,
    likeCount: 8,
    status: AppTravelStatus.completed,
    isPublic: true,
    backgroundImageUrl: '',
    completionRate: 75,
    isLiked: true,
  ),
];

@Preview(group: 'haerim', name: '찜 목록', size: Size(393, 700))
Widget likesContentPreview() => MaterialApp(
  home: Scaffold(
    backgroundColor: AppColors.white,
    body: LikesContent(
      travels: likesPreviewTravels(),
      onTravelTap: _ignoreTravelId,
      onFavoriteTap: _ignoreTravelId,
    ),
  ),
);

@Preview(group: 'haerim', name: '찜 목록 - 빈 상태', size: Size(393, 700))
Widget likesContentEmptyPreview() => const MaterialApp(
  home: Scaffold(
    backgroundColor: AppColors.white,
    body: LikesContent(travels: []),
  ),
);

void _ignoreTravelId(int _) {}

void _ignoreTap() {}
