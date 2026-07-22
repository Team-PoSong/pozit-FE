import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

const double _sheetRadius = 20.0;
const double _defaultExtent = 0.5;
const double _peekHeight = 100.0;
const double _handleTopOffset = 15.0;
const double _handleAreaHeight = 34.0;
const double _handleWidth = 55.0;
const double _handleHeight = 6.0;
const double _floatingButtonMargin = 16.0;

/// 지도 화면 위에 띄우는, 드래그로 펼치고 접을 수 있는 바텀 시트입니다.
///
/// 기본적으로 화면 높이의 50%를 차지하며, 드래그 핸들을 아래로 당기거나
/// 바텀 시트 바깥 영역을 탭하면 높이 100만큼만 남기고 접힙니다. 이 위젯은
/// 전체 화면 크기의 [Stack] 안에 직접 자식으로 넣어 사용해야 합니다.
class AppCourseBottomSheet extends StatefulWidget {
  const AppCourseBottomSheet({
    super.key,
    required this.child,
    this.showFloatingButton = true,
    this.onFloatingButtonTap,
  });

  final Widget child;

  /// 바텀 시트와 함께 움직이는 플로팅 버튼(GPS) 노출 여부
  final bool showFloatingButton;
  final VoidCallback? onFloatingButtonTap;

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
    final next = (_controller.size - delta).clamp(minChildSize, _defaultExtent);
    _controller.jumpTo(next);
  }

  void _handleDragEnd(double minChildSize) {
    final mid = (minChildSize + _defaultExtent) / 2;
    final target = _controller.size > mid ? _defaultExtent : minChildSize;
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
          initialChildSize: _defaultExtent,
          minChildSize: minChildSize,
          maxChildSize: _defaultExtent,
          snap: true,
          snapSizes: [minChildSize, _defaultExtent],
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
                        onVerticalDragEnd: (_) => _handleDragEnd(minChildSize),
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          physics: isPeeking
                              ? const NeverScrollableScrollPhysics()
                              : const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: isPeeking
                                ? Center(
                              child: Text(
                                '올려서 코스 자세히 보기',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.gray5,
                                ),
                              ),
                            )
                                : widget.child,
                          ),
                        );
                      },
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
