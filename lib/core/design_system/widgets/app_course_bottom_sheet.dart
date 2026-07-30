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
const double _floatingButtonMargin = 16.0;

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
    final minChildSize = math.min(
      _peekHeight / screenHeight,
      widget.maxChildSize,
    );

    final restingExtent = _defaultExtent.clamp(minChildSize, widget.maxChildSize);
    final isPeeking = _extent <= minChildSize + 0.01;
    final snapSizes = <double>{minChildSize, restingExtent, widget.maxChildSize}
        .toList()
      ..sort();

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
          snapSizes: snapSizes,
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
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.screenBottomPadding,
                            ),
                            child: SafeArea(
                              top: false,
                              child: SingleChildScrollView(
                                controller: scrollController,
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
