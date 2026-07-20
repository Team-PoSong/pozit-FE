import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_images.dart';
import '../app_text_styles.dart';
import 'app_badge.dart';

enum AppTravelCardType { pozitPick, myTravel, otherTravel }

enum AppTravelStatus { upcoming, inProgress, completed }

/// 여행 목록에서 공통으로 사용하는 카드입니다.
///
/// [backgroundImage]가 null이면 기본 포송 이미지가 표시됩니다.
/// [status]는 [AppTravelCardType.myTravel]일 때만 사용되며, 완료 상태에서만
/// [isPublic]에 따른 공개/비공개 아이콘이 표시됩니다.
class AppTravelCard extends StatelessWidget {
  const AppTravelCard({
    super.key,
    required this.type,
    required this.title,
    required this.location,
    required this.dateText,
    required this.author,
    this.status,
    this.dDay,
    this.tags = const [],
    this.participantCount,
    this.backgroundImage,
    this.isPublic = true,
    this.isFavorite = false,
    this.favoriteCount = 0,
    this.onTap,
    this.onFavoriteTap,
  }) : assert(
         type != AppTravelCardType.myTravel || status != null,
         '내 여행 카드는 status가 필요합니다.',
       );

  final AppTravelCardType type;
  final String title;
  final String location;
  final String dateText;
  final String author;
  final AppTravelStatus? status;
  final String? dDay;
  final List<String> tags;
  final int? participantCount;
  final ImageProvider<Object>? backgroundImage;
  final bool isPublic;
  final bool isFavorite;
  final int favoriteCount;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  bool get _isPozitPick => type == AppTravelCardType.pozitPick;
  bool get _isMyTravel => type == AppTravelCardType.myTravel;
  bool get _isOtherTravel => type == AppTravelCardType.otherTravel;
  bool get _showsVisibility =>
      type == AppTravelCardType.myTravel && status == AppTravelStatus.completed;

  ImageProvider<Object>? get _resolvedBackgroundImage => _isPozitPick
      ? backgroundImage ?? const AssetImage(AppImages.travelMockup)
      : backgroundImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 150,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isPozitPick
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 2,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(-1, -1),
                  ),
                ],
        ),
        foregroundDecoration: _isPozitPick
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1),
              )
            : null,
        child: Row(
          children: [
            _TravelCardThumbnail(
              image: _resolvedBackgroundImage,
              isPozitPick: _isPozitPick,
              isMyTravel: _isMyTravel,
              status: status,
              dDay: dDay,
              isPublic: isPublic,
              showVisibility: _showsVisibility,
              isOtherTravel: _isOtherTravel,
              isFavorite: isFavorite,
              favoriteCount: favoriteCount,
              onFavoriteTap: onFavoriteTap,
            ),
            Expanded(
              child: _TravelCardContent(
                title: title,
                location: location,
                dateText: dateText,
                tags: tags,
                author: author,
                participantCount: participantCount,
                isPozitPick: _isPozitPick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelCardThumbnail extends StatelessWidget {
  const _TravelCardThumbnail({
    required this.image,
    required this.isPozitPick,
    required this.isMyTravel,
    required this.status,
    required this.dDay,
    required this.isPublic,
    required this.showVisibility,
    required this.isOtherTravel,
    required this.isFavorite,
    required this.favoriteCount,
    required this.onFavoriteTap,
  });

  final ImageProvider<Object>? image;
  final bool isPozitPick;
  final bool isMyTravel;
  final AppTravelStatus? status;
  final String? dDay;
  final bool isPublic;
  final bool showVisibility;
  final bool isOtherTravel;
  final bool isFavorite;
  final int favoriteCount;
  final VoidCallback? onFavoriteTap;

  bool get _hasImage => image != null;

  String get _visibilityIcon {
    if (_hasImage) {
      return isPublic ? AppIcons.lockOpenWhite : AppIcons.lockClosedWhite;
    }
    return isPublic ? AppIcons.lockOpen : AppIcons.lockClosed;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_hasImage)
            Image(image: image!, fit: BoxFit.cover)
          else
            ColoredBox(
              color: AppColors.gray2,
              child: Center(
                child: Image.asset(
                  AppImages.posongPlainMini,
                  width: 60,
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (isPozitPick)
            const Positioned(left: 10, top: 10, child: _PozitPickBadge()),
          if (isMyTravel && status == AppTravelStatus.upcoming)
            Positioned(
              left: 10,
              top: 10,
              child: AppPillBadge(label: dDay ?? 'D-Day', isFilled: false),
            ),
          if (isMyTravel && status == AppTravelStatus.inProgress)
            const Positioned(
              left: 10,
              top: 10,
              child: AppPillBadge(label: '진행중'),
            ),
          if (showVisibility)
            Positioned(
              left: 10,
              top: 10,
              child: SvgPicture.asset(_visibilityIcon, width: 24, height: 24),
            ),
          if (isOtherTravel)
            Positioned(
              left: 13,
              top: 13,
              child: GestureDetector(
                onTap: onFavoriteTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      isFavorite
                          ? AppIcons.heartSmall
                          : AppIcons.heartSmallGray,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$favoriteCount',
                      style: AppTextStyles.caption2.copyWith(
                        color: _hasImage ? AppColors.white : AppColors.gray5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PozitPickBadge extends StatelessWidget {
  const _PozitPickBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.purple3, width: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Pozit ',
              style: AppTextStyles.caption2.copyWith(color: AppColors.primary),
            ),
            TextSpan(
              text: 'Pick!',
              style: AppTextStyles.caption2.copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelCardContent extends StatelessWidget {
  const _TravelCardContent({
    required this.title,
    required this.location,
    required this.dateText,
    required this.tags,
    required this.author,
    required this.participantCount,
    required this.isPozitPick,
  });

  final String title;
  final String location;
  final String dateText;
  final List<String> tags;
  final String author;
  final int? participantCount;
  final bool isPozitPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 18, 10, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 2,
            children: [
              Text(
                location,
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.purple3,
                ),
              ),
              Text(
                dateText,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 20,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) => _TravelTag(label: tags[index]),
            ),
          ),
          const Spacer(),
          if (isPozitPick)
            Text(
              author,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray5,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Row(
              children: [
                SvgPicture.asset(AppIcons.groupGray, width: 16, height: 16),
                const SizedBox(width: 5),
                Text(
                  participantCount == null
                      ? author
                      : '$author 외 $participantCount명',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray5,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TravelTag extends StatelessWidget {
  const _TravelTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = label.startsWith('#') ? label : '# $label';
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.travelTagBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.gray5,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1,
        ),
      ),
    );
  }
}

Widget _travelCardPreview(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - Pozit Pick')
Widget appTravelCardPozitPickPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.pozitPick,
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '포송',
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 예정 / 사진 있음')
Widget appTravelCardUpcomingWithPhotoPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.myTravel,
      status: AppTravelStatus.upcoming,
      dDay: 'D-24',
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
      backgroundImage: AssetImage(AppImages.travelMockup),
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 예정 / 사진 없음')
Widget appTravelCardUpcomingWithoutPhotoPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.myTravel,
      status: AppTravelStatus.upcoming,
      dDay: 'D-24',
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 진행 중 / 사진 있음')
Widget appTravelCardInProgressPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.myTravel,
      status: AppTravelStatus.inProgress,
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
      backgroundImage: AssetImage(AppImages.travelMockup),
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 완료 / 공개 / 사진 있음')
Widget appTravelCardCompletedPublicPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.myTravel,
      status: AppTravelStatus.completed,
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
      backgroundImage: AssetImage(AppImages.travelMockup),
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 완료 / 비공개 / 사진 없음')
Widget appTravelCardCompletedPrivatePreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.myTravel,
      status: AppTravelStatus.completed,
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
      isPublic: false,
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 다른 사용자 / 찜')
Widget appTravelCardOtherFavoritePreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.otherTravel,
      title: '경주 여행',
      location: '경북 경주',
      dateText: '7/2 ~ 7/3',
      tags: ['힐링', '미식'],
      author: '해림',
      participantCount: 2,
      backgroundImage: AssetImage(AppImages.travelMockup),
      isFavorite: true,
      favoriteCount: 14,
    ),
  );
}

@Preview(group: 'hycho', name: 'Travel Card - 다른 사용자 / 찜 안 함 / 사진 없음')
Widget appTravelCardOtherWithoutPhotoPreview() {
  return _travelCardPreview(
    const AppTravelCard(
      type: AppTravelCardType.otherTravel,
      title: '강릉 데이트',
      location: '강원 강릉',
      dateText: '7/2 ~ 7/3',
      tags: ['문화', '탐험'],
      author: '민서',
      participantCount: 2,
      favoriteCount: 14,
    ),
  );
}
