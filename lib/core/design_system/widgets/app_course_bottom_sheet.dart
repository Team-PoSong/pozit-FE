import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

const double _sheetRadius = 20.0;
const double _defaultExtent = 0.5;
const double _handleTopOffset = 15.0;
const double _handleAreaHeight = 20.0;
const double _handleWidth = 55.0;
const double _handleHeight = 6.0;
const double _floatingButtonRightMargin = 16.0;
const double _floatingButtonBottomGap = 18.0;

// 드래그 핸들(회색 바) 하단에서 '올려서 코스 자세히 보기' 텍스트까지의 간격.
const double _kHandleToPeekTextGap = 10.0;
const double _kPeekTextTopGap =
    _kHandleToPeekTextGap - (_handleAreaHeight - _handleHeight) / 2;
const double _kPeekTextBottomGap = 70.0;

const double _kPeekExtraBuffer = 20.0;

const double _peekHeight =
    _handleTopOffset +
    _handleAreaHeight +
    _kPeekTextTopGap +
    24 +
    _kPeekTextBottomGap +
    _kPeekExtraBuffer;

class AppCourseBottomSheet extends StatefulWidget {
  static const double defaultRestingExtent = _defaultExtent;

  const AppCourseBottomSheet({
    super.key,
    required this.child,
    this.showFloatingButton = true,
    this.onFloatingButtonTap,
    this.maxChildSize = _defaultExtent,
  }) : assert(
         maxChildSize > 0 && maxChildSize <= 1,
         'maxChildSize는 0보다 크고 1 이하여야 합니다.',
       );

  final Widget child;

  final bool showFloatingButton;
  final VoidCallback? onFloatingButtonTap;

  final double maxChildSize;

  @override
  State<AppCourseBottomSheet> createState() => _AppCourseBottomSheetState();
}

class _AppCourseBottomSheetState extends State<AppCourseBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  // 목록 스크롤은 시트 크기와 완전히 분리합니다. DraggableScrollableSheet가
  // builder에 넘겨주는 scrollController를 목록에 그대로 쓰면, 목록을 위로
  // 당길 때 시트가 먼저 최대 크기까지 펼쳐진 다음에야 스크롤되는 내장 동작이
  // 발생합니다. 그 동작을 원치 않으므로 별도의 일반 ScrollController를 씁니다.
  final ScrollController _contentScrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  void _collapse(double minChildSize) {
    if (!_controller.isAttached || _controller.size <= minChildSize + 0.001) {
      return;
    }
    _controller.animateTo(
      minChildSize,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _handleDragUpdate(
    DragUpdateDetails details,
    double screenHeight,
    double minChildSize,
  ) {
    if (!_controller.isAttached) return;
    final delta = details.delta.dy / screenHeight;
    final next = (_controller.size - delta).clamp(
      minChildSize,
      widget.maxChildSize,
    );
    _controller.jumpTo(next);
  }

  void _handleDragEnd(double minChildSize, double restingExtent) {
    if (!_controller.isAttached) return;
    final snapPoints = <double>{minChildSize, restingExtent, widget.maxChildSize}
        .toList()
      ..sort();
    final target = snapPoints.reduce(
      (closest, point) =>
          (_controller.size - point).abs() < (_controller.size - closest).abs()
          ? point
          : closest,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  double _currentExtent(double restingExtent) =>
      _controller.isAttached ? _controller.size : restingExtent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final minChildSize = math.min(
      _peekHeight / screenHeight,
      widget.maxChildSize,
    );

    final restingExtent = _defaultExtent.clamp(minChildSize, widget.maxChildSize);
    final snapSizes = <double>{minChildSize, restingExtent, widget.maxChildSize}
        .toList()
      ..sort();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 시트 위쪽(지도 영역)을 탭하면 접히는 레이어입니다. bottom을 시트 높이만큼
        // 띄워서 시트 영역과 겹치지 않게 해야, 리스트의 스크롤/드래그 제스처가
        // 이 레이어와 경합하지 않고 정상적으로 인식됩니다.
        //
        // AnimatedBuilder로 감싸 _controller의 사이즈 변화에만 반응하도록
        // 격리합니다. 이 위젯을 AppCourseBottomSheet.build() 안에서 직접
        // setState로 갱신하면 DraggableScrollableSheet 위젯 자체가 매번
        // 새로 생성되어, Flutter가 내부적으로 didUpdateWidget에서
        // extent를 통째로 교체(_replaceExtent)합니다. 이는 진행 중인
        // 드래그/스크롤 제스처를 매 프레임 끊어버려 목록이 스크롤되지
        // 않거나 컨트롤러 연결이 끊기는 원인이 되므로, 시트와 무관한
        // 위젯만 별도로 리빌드되게 분리했습니다.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final extent = _currentExtent(restingExtent);
            final isPeeking = extent <= minChildSize + 0.01;
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: screenHeight * extent,
              child: IgnorePointer(
                ignoring: isPeeking,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _collapse(minChildSize),
                ),
              ),
            );
          },
        ),
        DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: restingExtent,
          minChildSize: minChildSize,
          maxChildSize: widget.maxChildSize,
          snap: true,
          snapSizes: snapSizes,
          builder: (context, scrollController) {
            return Stack(
              children: [
                // DraggableScrollableController는 builder가 넘겨준
                // scrollController가 실제 Scrollable에 연결되어 있을 때만
                // isAttached가 true가 된다(핸들 드래그의 jumpTo/animateTo에 필요).
                // 목록은 시트 크기와 무관하게 독립적으로 스크롤되어야 하므로,
                // 이 scrollController는 화면에 보이지 않는 크기 0짜리
                // Scrollable에만 연결해 둔다.
                SizedBox(
                  width: 0,
                  height: 0,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: _handleTopOffset),
                        child: SizedBox(
                          height: _handleAreaHeight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (details) =>
                                _handleDragUpdate(
                                  details,
                                  screenHeight,
                                  minChildSize,
                                ),
                            onVerticalDragEnd: (_) =>
                                _handleDragEnd(minChildSize, restingExtent),
                            child: Center(
                              child: Container(
                                width: _handleWidth,
                                height: _handleHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.gray4,
                                  borderRadius: BorderRadius.circular(
                                    _handleHeight / 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        // isPeeking은 시트 크기(_controller)에 따라 매 프레임
                        // 바뀌어야 하는 값입니다. 하지만 이 builder 콜백 자체는
                        // 상위 DraggableScrollableSheet의 크기 애니메이션
                        // (FractionallySizedBox) 프레임마다 다시 호출되지 않고,
                        // 위젯이 새로 생성될 때만 호출됩니다. 따라서
                        // AnimatedBuilder로 별도로 감싸서 드래그 중에도 피크
                        // 텍스트 ↔ 목록 전환이 실시간으로 반영되게 합니다.
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final isPeeking =
                                _currentExtent(restingExtent) <=
                                minChildSize + 0.01;
                            return isPeeking
                                ? GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onVerticalDragUpdate: (details) =>
                                        _handleDragUpdate(
                                          details,
                                          screenHeight,
                                          minChildSize,
                                        ),
                                    onVerticalDragEnd: (_) => _handleDragEnd(
                                      minChildSize,
                                      restingExtent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: _kPeekTextTopGap,
                                        bottom: _kPeekTextBottomGap,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '올려서 코스 자세히 보기',
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.gray5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                // 목록 스크롤은 시트 크기와 완전히 독립적으로
                                // 동작해야 하므로, 시트가 제공하는
                                // scrollController가 아닌 별도의
                                // _contentScrollController를 사용합니다. 이렇게
                                // 하면 목록을 위로 당겨도 시트가 펼쳐지지 않고
                                // 내부 콘텐츠만 스크롤됩니다(시트 크기 조절은
                                // 핸들 드래그로만 가능).
                                : SafeArea(
                                    top: false,
                                    // bottom padding을 바깥 Padding으로 주면
                                    // 스크롤 뷰포트 자체가 그만큼 줄어들어,
                                    // 끝까지 스크롤해도 마지막 카드가 불필요하게
                                    // 더 잘려 보입니다. SingleChildScrollView의
                                    // padding으로 주면 뷰포트는 그대로 두고
                                    // 콘텐츠 뒤쪽 여백만 늘어납니다.
                                    child: SingleChildScrollView(
                                      controller: _contentScrollController,
                                      physics: const ClampingScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                        bottom: AppDimensions.screenBottomPadding,
                                      ),
                                      child: widget.child,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.showFloatingButton)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final extent = _currentExtent(restingExtent);
              // 시트가 완전히 펼쳐졌을 때는 버튼을 숨깁니다.
              final isFullyExpanded = extent >= widget.maxChildSize - 0.001;
              if (isFullyExpanded) return const SizedBox.shrink();
              return Positioned(
                right: _floatingButtonRightMargin,
                bottom: extent * screenHeight + _floatingButtonBottomGap,
                child: GestureDetector(
                  onTap: widget.onFloatingButtonTap,
                  child: SvgPicture.asset(
                    AppIcons.map,
                    width: 36.0,
                    height: 36.0,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

@Preview(group: 'Seohyun', name: 'AppCourseBottomSheet', size: Size(390, 844))
Widget appCourseBottomSheetPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.gray2),
          AppCourseBottomSheet(
            showFloatingButton: true,
            onFloatingButtonTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('코스 상세', style: AppTextStyles.headline),
                  const SizedBox(height: 12.0),
                  Text(
                    '드래그해서 펼치거나 접어보세요.',
                    style: AppTextStyles.body.copyWith(color: AppColors.gray5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
