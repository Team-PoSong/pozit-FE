import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';

const double _kHorizontalPadding = 24.0;

const double _kHighlightPaddingHorizontal = 5.0;
const double _kHighlightPaddingTop = 3.0;
const double _kHighlightPaddingBottom = 4.0;
const double _kHighlightContentHeight = 14.0;

const double _kPointerHeight = 36.0;
const double _kPointerWidth = _kPointerHeight * 36 / 128;
const double _kPointerToTextGap = 6.0;
const double _kCameraPointerToTextGap = 5.0;
const double _kCameraOutlineBorderWidth = 1.0;
const double _kCameraOutlineBorderRadius = 12.0;
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

class TravelDetailGuideOverlay extends StatefulWidget {
  const TravelDetailGuideOverlay({
    super.key,
    required this.courseButtonKey,
    required this.mapKey,
    this.cameraKey,
    required this.onDismiss,
    required this.onDismissForever,
  });

  final GlobalKey courseButtonKey;
  final GlobalKey mapKey;
  final GlobalKey? cameraKey;

  final VoidCallback onDismiss;

  final VoidCallback onDismissForever;

  @override
  State<TravelDetailGuideOverlay> createState() =>
      _TravelDetailGuideOverlayState();
}

class _TravelDetailGuideOverlayState extends State<TravelDetailGuideOverlay> {
  final GlobalKey _rootKey = GlobalKey();
  Rect? _courseButtonRect;
  Rect? _mapRect;
  Rect? _cameraRect;

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

    final cameraBox =
        widget.cameraKey?.currentContext?.findRenderObject() as RenderBox?;

    setState(() {
      _courseButtonRect =
          (courseBox.localToGlobal(Offset.zero, ancestor: rootBox)) &
          courseBox.size;
      _mapRect =
          (mapBox.localToGlobal(Offset.zero, ancestor: rootBox)) &
          mapBox.size;
      _cameraRect = cameraBox == null
          ? null
          : (cameraBox.localToGlobal(Offset.zero, ancestor: rootBox)) &
                cameraBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    final courseButtonRect = _courseButtonRect;
    final mapRect = _mapRect;
    final cameraRect = _cameraRect;

    Rect? highlightRect;
    if (courseButtonRect != null) {
      final center = courseButtonRect.center;
      highlightRect = Rect.fromLTRB(
        center.dx - courseButtonRect.width / 2 - _kHighlightPaddingHorizontal,
        center.dy - _kHighlightContentHeight / 2 - _kHighlightPaddingTop,
        center.dx + courseButtonRect.width / 2 + _kHighlightPaddingHorizontal,
        center.dy + _kHighlightContentHeight / 2 + _kHighlightPaddingBottom,
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
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(
                              _kHighlightPaddingHorizontal,
                              _kHighlightPaddingTop,
                              _kHighlightPaddingHorizontal,
                              _kHighlightPaddingBottom,
                            ),
                            child: _HighlightedCourseLabel(),
                          ),
                        ),
                      ),
                    ),

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
                  if (cameraRect != null) ...[
                    Positioned(
                      left: cameraRect.left,
                      top: cameraRect.top,
                      width: cameraRect.width,
                      height: cameraRect.height,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              _kCameraOutlineBorderRadius,
                            ),
                            border: Border.all(
                              color: AppColors.gray5,
                              width: _kCameraOutlineBorderWidth,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: cameraRect.center.dx - _kPointerWidth / 2,
                      bottom: screenSize.height - cameraRect.top,
                      child: const _GuidePointer(),
                    ),
                    Positioned(
                      left: cameraRect.left,
                      width: cameraRect.width,
                      bottom:
                          screenSize.height -
                          cameraRect.top +
                          _kPointerHeight +
                          _kCameraPointerToTextGap,
                      child: const Text(
                        '카메라가 활성화되면\n포징을 촬영할 수 있어요!',
                        textAlign: TextAlign.center,
                        style: _kTooltipTextStyle,
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
