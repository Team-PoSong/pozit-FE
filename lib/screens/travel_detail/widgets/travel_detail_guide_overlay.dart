import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';

const double _kHorizontalPadding = 24.0;
const Size _kHighlightSize = Size(64, 21);
// img_pointer.png의 원본 비율(36x128)을 유지한 채 길이 36으로 표시합니다.
const double _kPointerHeight = 36.0;
const double _kPointerWidth = _kPointerHeight * 36 / 128;
const double _kPointerToTextGap = 6.0;
const Duration _kFadeOutDuration = Duration(milliseconds: 220);

const TextStyle _kTooltipTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 16,
  height: 20 / 16,
  fontWeight: FontWeight.w500,
  color: AppColors.white,
);

const TextStyle _kDismissTextStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 16,
  height: 20 / 16,
  fontWeight: FontWeight.w400,
  color: AppColors.gray1,
  decoration: TextDecoration.underline,
  decorationColor: AppColors.gray1,
);

/// 여행 상세 화면에 처음(또는 '다신 보지 않기'를 누르기 전까지 매번) 들어올 때
/// 뜨는 사용자 설명(코치마크)입니다.
///
/// 화면 전체를 반투명 검정으로 덮고, [courseButtonKey]가 가리키는 '코스 보기'
/// 버튼과 [mapKey]가 가리키는 지도 영역의 실제 렌더링 위치를 측정해 그 위에
/// 설명 문구를 얹습니다. 좌표를 직접 계산하지 않고 [AppCalendar]와 동일하게
/// GlobalKey로 실제 위치를 측정하는 방식이라, 두 위젯의 레이아웃이 조금
/// 바뀌어도 설명 위치가 함께 따라갑니다.
class TravelDetailGuideOverlay extends StatefulWidget {
  const TravelDetailGuideOverlay({
    super.key,
    required this.courseButtonKey,
    required this.mapKey,
    required this.onDismiss,
    required this.onDismissForever,
  });

  final GlobalKey courseButtonKey;
  final GlobalKey mapKey;

  /// 화면 아무 곳이나 탭했을 때(이번 한 번만 닫힘, 다음에 다시 뜰 수 있음).
  final VoidCallback onDismiss;

  /// '다신 보지 않기'를 눌렀을 때(이후로는 계속 뜨지 않음).
  final VoidCallback onDismissForever;

  @override
  State<TravelDetailGuideOverlay> createState() =>
      _TravelDetailGuideOverlayState();
}

class _TravelDetailGuideOverlayState extends State<TravelDetailGuideOverlay> {
  final GlobalKey _rootKey = GlobalKey();
  Rect? _courseButtonRect;
  Rect? _mapRect;

  // '다신 보지 않기'/바깥 탭으로 닫힐 때, 위젯이 트리에서 바로 빠지며
  // 뚝 끊겨 보이지 않도록 먼저 투명도를 낮춘 뒤에 실제 콜백을 호출합니다.
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  Future<void> _fadeOutThen(VoidCallback callback) async {
    if (!_visible || !mounted) return;
    setState(() => _visible = false);
    await Future.delayed(_kFadeOutDuration);
    if (!mounted) return;
    callback();
  }

  void _measure() {
    if (!mounted) return;
    final rootBox = _rootKey.currentContext?.findRenderObject() as RenderBox?;
    final courseBox =
        widget.courseButtonKey.currentContext?.findRenderObject()
            as RenderBox?;
    final mapBox =
        widget.mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (rootBox == null || courseBox == null || mapBox == null) return;

    setState(() {
      _courseButtonRect =
          (courseBox.localToGlobal(Offset.zero, ancestor: rootBox)) &
          courseBox.size;
      _mapRect =
          (mapBox.localToGlobal(Offset.zero, ancestor: rootBox)) &
          mapBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    final courseButtonRect = _courseButtonRect;
    final mapRect = _mapRect;

    // '코스 보기'를 밝히는 상자는 실제 버튼 위치(측정된 중심)에 고정
    // 크기(64x21)로 얹습니다. '스와이프 하여 장소 이동' 문구는 이 상자
    // 기준으로 세로 39px 아래에 옵니다.
    Rect? highlightRect;
    if (courseButtonRect != null) {
      highlightRect = Rect.fromCenter(
        center: courseButtonRect.center,
        width: _kHighlightSize.width,
        height: _kHighlightSize.height,
      );
    }

    const swipeHintLineHeight = 20.0;
    final swipeHintCenterY = highlightRect != null
        ? highlightRect.bottom + 39 + swipeHintLineHeight / 2
        : null;

    return Positioned.fill(
      child: SizedBox.expand(
        key: _rootKey,
        child: IgnorePointer(
          ignoring: !_visible,
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: _kFadeOutDuration,
            curve: Curves.easeOut,
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _fadeOutThen(widget.onDismiss),
                      child: ColoredBox(
                        color: const Color(0xFF262626).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  if (highlightRect != null)
                    Positioned(
                      left: highlightRect.left,
                      top: highlightRect.top,
                      width: highlightRect.width,
                      height: highlightRect.height,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: _HighlightedCourseLabel(),
                          ),
                        ),
                      ),
                    ),
                  // 포인터(점·선·화살표)는 '코스 보기' 상자의 가로 중앙을
                  // 향해야 하므로, 오른쪽 정렬인 설명 문구와 별도로 각각
                  // 위치를 잡습니다.
                  if (highlightRect != null) ...[
                    Positioned(
                      left: highlightRect.center.dx - _kPointerWidth / 2,
                      bottom: screenSize.height - highlightRect.top,
                      child: const _GuidePointer(),
                    ),
                    Positioned(
                      right: screenSize.width - highlightRect.right,
                      bottom:
                          screenSize.height -
                          highlightRect.top +
                          _kPointerHeight +
                          _kPointerToTextGap,
                      child: const SizedBox(
                        width: 200,
                        child: Text(
                          '세부 코스는 코스 보기를\n통해 볼 수 있어요.',
                          textAlign: TextAlign.right,
                          style: _kTooltipTextStyle,
                        ),
                      ),
                    ),
                  ],
                  if (mapRect != null && swipeHintCenterY != null) ...[
                    Positioned(
                      left: mapRect.left,
                      top: swipeHintCenterY - swipeHintLineHeight / 2,
                      width: mapRect.width,
                      height: swipeHintLineHeight,
                      child: const Center(
                        child: Text(
                          '스와이프 하여 장소 이동',
                          style: _kTooltipTextStyle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _kHorizontalPadding,
                      top: swipeHintCenterY - 9,
                      child: SvgPicture.asset(
                        AppIcons.arrowLeftWhite,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    Positioned(
                      right: _kHorizontalPadding,
                      top: swipeHintCenterY - 9,
                      child: SvgPicture.asset(
                        AppIcons.arrowRight,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ],
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomSafePadding + 40,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _fadeOutThen(widget.onDismissForever),
                        child: const Text(
                          '다신 보지 않기',
                          style: _kDismissTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 실제 '코스 보기' 버튼 자리에 새로 그리는, 흰 글씨의 '코스 보기 >'
/// 라벨입니다. 어둡게 딤 처리된 화면 위로 원래 버튼(회색 글씨)이 그대로
/// 비치면 잘 안 보이므로, 하이라이트 상자 위에 흰색으로 다시 그립니다.
class _HighlightedCourseLabel extends StatelessWidget {
  const _HighlightedCourseLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '코스 보기',
          style: AppTextStyles.caption.copyWith(color: AppColors.white),
        ),
        const SizedBox(width: 4),
        SvgPicture.asset(
          AppIcons.arrowRightSmallWhite,
          width: 14,
          height: 14,
        ),
      ],
    );
  }
}

/// '코스 보기' 상자 중앙을 가리키는 점(원 안에 원) + 선 + 화살표입니다.
class _GuidePointer extends StatelessWidget {
  const _GuidePointer();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.pointer,
      width: _kPointerWidth,
      height: _kPointerHeight,
    );
  }
}

class _TravelDetailGuideOverlayPreview extends StatefulWidget {
  const _TravelDetailGuideOverlayPreview();

  @override
  State<_TravelDetailGuideOverlayPreview> createState() =>
      _TravelDetailGuideOverlayPreviewState();
}

class _TravelDetailGuideOverlayPreviewState
    extends State<_TravelDetailGuideOverlayPreview> {
  final _courseButtonKey = GlobalKey();
  final _mapKey = GlobalKey();
  bool _showGuide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray2,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  key: _courseButtonKey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: const Text('코스 보기'),
                ),
                const SizedBox(height: 13),
                Container(
                  key: _mapKey,
                  width: double.infinity,
                  height: 156,
                  color: AppColors.gray4,
                ),
              ],
            ),
          ),
          if (_showGuide)
            TravelDetailGuideOverlay(
              courseButtonKey: _courseButtonKey,
              mapKey: _mapKey,
              onDismiss: () => setState(() => _showGuide = false),
              onDismissForever: () => setState(() => _showGuide = false),
            ),
        ],
      ),
    );
  }
}

@Preview(group: 'travel_detail', name: 'GuideOverlay', size: Size(390, 844))
Widget travelDetailGuideOverlayPreview() {
  return const MaterialApp(home: _TravelDetailGuideOverlayPreview());
}
