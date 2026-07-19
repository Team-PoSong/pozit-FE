import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_images.dart';
import '../app_text_styles.dart';

/// 여행 코스의 지도 미리보기를 보여주는 카드입니다.
///
/// 실제 지도 연동 전에는 [mapImage]에 정적 이미지를 사용하고, 연동 후에는
/// 현재 코스 장소에 맞는 이미지와 [currentPage]를 전달할 수 있습니다.
class AppMapCard extends StatelessWidget {
  const AppMapCard({
    super.key,
    required this.title,
    this.mapImage = const AssetImage(AppImages.mapMiniMock),
    this.currentPage = 0,
    this.pageCount = 4,
    this.onCourseTap,
  }) : assert(pageCount > 0, 'pageCount는 1 이상이어야 합니다.'),
       assert(
         currentPage >= 0 && currentPage < pageCount,
         'currentPage는 pageCount 범위 안이어야 합니다.',
       );

  final String title;
  final ImageProvider<Object> mapImage;
  final int currentPage;
  final int pageCount;
  final VoidCallback? onCourseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 233,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: AppColors.gray4, blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 47,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 76),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subTitle.copyWith(
                      color: AppColors.gray5,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  child: _CourseAction(onTap: onCourseTap),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: mapImage,
                width: double.infinity,
                height: 156,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _PageIndicator(
                currentPage: currentPage,
                pageCount: pageCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseAction extends StatelessWidget {
  const _CourseAction({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '코스 보기',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray5,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              AppIcons.arrowRightSmall,
              width: 14,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        pageCount,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == pageCount - 1 ? 0 : 12),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == currentPage
                  ? AppColors.primary
                  : AppColors.gray3,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Map Card')
Widget appMapCardPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: AppMapCard(title: '연꽃단지'),
        ),
      ),
    ),
  );
}
