import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_images.dart';
import '../app_text_styles.dart';

const Duration _kTransitionDuration = Duration(milliseconds: 260);

/// 제목/지도/인디케이터가 공통으로 쓰는 전환 효과입니다. 위치나 크기를
/// 바꾸지 않고, 있는 그대로의 위젯을 옆에서 미끄러져 들어오며 페이드인
/// 하는 것처럼만 보이게 감싸줍니다.
Widget _slideFadeTransition(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}

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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: AppColors.gray4, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    // 지도를 옆으로 넘기면 코스가 바뀌었다는 걸 체감할 수
                    // 있도록, 제목 텍스트만 옆으로 미끄러지듯 전환합니다.
                    // 인디케이터 점은 원래 모양 그대로 유지합니다.
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: _kTransitionDuration,
                        switchInCurve: Curves.easeInOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        transitionBuilder: _slideFadeTransition,
                        child: Text(
                          title,
                          key: ValueKey(title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.subTitle.copyWith(
                            color: AppColors.gray5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                AspectRatio(
                  aspectRatio: 319 / 156,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: mapImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _PageIndicator(currentPage: currentPage, pageCount: pageCount),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 12,
            child: _CourseAction(onTap: onCourseTap),
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
      child: SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '코스 보기',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray5,
                  fontWeight: FontWeight.w300,
                  height: 14 / 12,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(AppIcons.arrowRightSmall, width: 14, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.pageCount});

  final int currentPage;
  final int pageCount;

  static const double _dotSize = 8;
  static const double _dotGap = 12;

  @override
  Widget build(BuildContext context) {
    final trackWidth = pageCount * _dotSize + (pageCount - 1) * _dotGap;
    // AppDateDetailSelect의 슬라이딩 인디케이터와 동일한 -1~1 보간식입니다.
    final alignmentX = pageCount == 1
        ? 0.0
        : -1 + 2 * (currentPage / (pageCount - 1));

    // 부모 Column이 crossAxisAlignment.stretch라 여기 바로 SizedBox를 두면
    // 카드 전체 너비로 강제로 늘어나 점 간격이 벌어져 보였던 게 지난번
    // 문제였습니다. Center로 한 번 감싸 느슨한 제약을 준 다음 그 안에서
    // SizedBox가 실제로 원하는 trackWidth만큼만 차지하도록 합니다.
    return Center(
      child: SizedBox(
        width: trackWidth,
        height: _dotSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                pageCount,
                (_) => const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.gray3,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: _dotSize, height: _dotSize),
                ),
              ),
            ),
            AnimatedAlign(
              duration: _kTransitionDuration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment(alignmentX, 0),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: _dotSize, height: _dotSize),
              ),
            ),
          ],
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
