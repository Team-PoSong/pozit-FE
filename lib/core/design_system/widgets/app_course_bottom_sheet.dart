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
const double _handleAreaHeight = 34.0;
const double _handleWidth = 55.0;
const double _handleHeight = 6.0;
const double _floatingButtonMargin = 16.0;

// 드래그 핸들 영역(_handleTopOffset+_handleAreaHeight, 총 49px) 바로 아래
// 안내 문구까지의 간격과, 그 문구 아래쪽 여백입니다.
const double _kPeekTextTopGap = 20.0;
const double _kPeekTextBottomGap = 50.0;

// 접힌 상태 전체 높이에 더해주는 추가 여유분입니다.
const double _kPeekExtraBuffer = 20.0;

// 접힌 상태의 전체 높이입니다. 핸들 영역(_handleTopOffset+_handleAreaHeight)
// + 핸들-문구 간격(_kPeekTextTopGap) + 안내 문구 한 줄(AppTextStyles.body
// 기준 24px) + 문구 아래 여백(_kPeekTextBottomGap) + 추가 여유분
// (_kPeekExtraBuffer)을 모두 더한 값입니다: 15+34+20+24+50+20 = 163.
const double _peekHeight =
    _handleTopOffset +
    _handleAreaHeight +
    _kPeekTextTopGap +
    24 +
    _kPeekTextBottomGap +
    _kPeekExtraBuffer;

/// 지도 화면 위에 띄우는, 드래그로 펼치고 접을 수 있는 바텀 시트입니다.
///
/// 기본적으로 화면 높이의 50%를 차지하며, 드래그 핸들을 아래로 당기거나
/// 바텀 시트 바깥 영역을 탭하면 [_peekHeight]만큼만 남기고 접힙니다. 이
/// 위젯은 전체 화면 크기의 [Stack] 안에 직접 자식으로 넣어 사용해야 합니다.
class AppCourseBottomSheet extends StatefulWidget {
  /// 바텀 시트가 기본으로 펼쳐져 있는 높이 비율(화면 높이 대비)입니다. 이
  /// 시트 아래에 깔린 지도가 이 영역만큼 가려진다는 뜻이므로, 지도의 카메라를
  /// 맞출 때 가려지지 않는 위쪽 영역만 기준으로 삼고 싶다면 이 값을
  /// 참고하세요.
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

  /// 바텀 시트와 함께 움직이는 플로팅 버튼(GPS) 노출 여부
  final bool showFloatingButton;
  final VoidCallback? onFloatingButtonTap;

  /// 드래그로 펼칠 수 있는 최대 높이 비율(화면 높이 대비)입니다. 기본값은
  /// 화면의 절반이며, 코스 보기 화면처럼 탑 바 바로 아래까지 완전히 펼쳐야
  /// 하는 경우 더 큰 값을 넘겨주면 됩니다.
  final double maxChildSize;

  @override
  State<AppCourseBottomSheet> createState() => _AppCourseBottomSheetState();
}

class _AppCourseBottomSheetState extends State<AppCourseBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  double _extent = _defaultExtent;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleExtentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleExtentChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleExtentChanged() => setState(() => _extent = _controller.size);

  void _collapse(double minChildSize) {
    if (_controller.size <= minChildSize + 0.001) return;
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
    final delta = details.delta.dy / screenHeight;
    final next = (_controller.size - delta).clamp(
      minChildSize,
      widget.maxChildSize,
    );
    _controller.jumpTo(next);
  }

  // 드래그를 놓으면 가장 가까운 스냅 지점(접힘/기본/최대 펼침)으로 붙습니다.
  void _handleDragEnd(double minChildSize, double restingExtent) {
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final minChildSize = _peekHeight / screenHeight;
    // 최대치가 기본 펼침 값(50%)보다 작게 지정된 예외적인 경우에도, 초기/기본
    // 상태가 항상 지정 가능한 범위 안에 들어오게 합니다.
    final restingExtent = _defaultExtent.clamp(minChildSize, widget.maxChildSize);
    final isPeeking = _extent <= minChildSize + 0.01;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isPeeking,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _collapse(minChildSize),
            ),
          ),
        ),
        DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: restingExtent,
          minChildSize: minChildSize,
          maxChildSize: widget.maxChildSize,
          snap: true,
          snapSizes: [minChildSize, restingExtent],
          builder: (context, scrollController) {
            return DecoratedBox(
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
                        onVerticalDragUpdate: (details) => _handleDragUpdate(
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
                  // DraggableScrollableSheet는 이 scrollController가 실제
                  // Scrollable에 붙어 있기를 기대하지만, 여기 붙이면 시트가
                  // maxChildSize에 도달하기 전까지는 본문을 드래그해도 시트
                  // 크기만 늘어나고 목록 스크롤은 시작되지 않습니다(끝까지
                  // 펼친 뒤 손을 떼고 다시 스와이프해야만 스크롤됨). 시트
                  // 크기 조절은 위 핸들 제스처가 전담하므로, 여기서는
                  // 아무 것도 스크롤하지 않는 크기 0짜리 더미에만 붙여 시트
                  // 리사이즈와 목록 스크롤을 완전히 분리합니다. 그 결과 목록은
                  // 시트가 반쯤 펼쳐진 상태에서도 바로 스크롤됩니다.
                  SizedBox(
                    height: 0,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ),
                  Expanded(
                    child: isPeeking
                        ? Padding(
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
                          )
                        : Padding(
                            // 시트 배경(흰색)은 화면 맨 아래까지 그대로
                            // 채우되, 실제 내용은 기기 하단 제스처 바 위로
                            // 올려서 마지막 항목이 그 아래 가려지지 않게
                            // 합니다. 안전 영역만큼만 띄우면 마지막 항목이
                            // 제스처 바 바로 위에 붙어 보여서,
                            // screenBottomPadding만큼 여유를 더 둡니다.
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.screenBottomPadding,
                            ),
                            child: SafeArea(
                              top: false,
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: widget.child,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.showFloatingButton)
          Positioned(
            right: _floatingButtonMargin,
            bottom: _extent * screenHeight + _floatingButtonMargin,
            child: GestureDetector(
              onTap: widget.onFloatingButtonTap,
              child: SvgPicture.asset(AppIcons.gps, width: 36.0, height: 36.0),
            ),
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
