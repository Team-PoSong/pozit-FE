import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_dimensions.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/button/app_button.dart';

const double _kHorizontalPadding = 24.0;
const double _kTopPadding = 15.0;
const double _kMessageToFavoriteGap = 14.0;
const double _kButtonGap = 8.0;

class TravelDetailPublicActions extends StatelessWidget {
  const TravelDetailPublicActions({
    super.key,
    required this.authorName,
    required this.isFavorite,
    this.onFavoriteTap,
    this.onFollowCourseTap,
  });

  final String authorName;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onFollowCourseTap;

  @override
  Widget build(BuildContext context) {
    final displayName = authorName.isEmpty ? '여행자' : authorName;

    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _kHorizontalPadding,
          _kTopPadding,
          _kHorizontalPadding,
          AppDimensions.screenBottomPadding +
              MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$displayName님의 여행 코스를\n내 여행으로 가져와볼까요?',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: _kMessageToFavoriteGap),
            AppFavoriteButton(isFavorite: isFavorite, onPressed: onFavoriteTap),
            const SizedBox(height: _kButtonGap),
            AppButton(
              text: '이 코스 따라하기',
              isEnabled: onFollowCourseTap != null,
              disabledBackgroundColor: AppColors.primary,
              disabledContentColor: AppColors.white,
              onPressed: onFollowCourseTap,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '공개 여행 하단 액션', size: Size(393, 230))
Widget travelDetailPublicActionsPreview() => const MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: TravelDetailPublicActions(
        authorName: '민서',
        isFavorite: true,
        onFavoriteTap: _ignoreTap,
        onFollowCourseTap: _ignoreTap,
      ),
    ),
  ),
);

void _ignoreTap() {}
