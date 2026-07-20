import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

class AppDensityTrack extends StatefulWidget {
  final int? selectedIndex;
  final ValueChanged<int>? onLevelSelected;

  const AppDensityTrack({super.key, this.selectedIndex, this.onLevelSelected});

  @override
  State<AppDensityTrack> createState() => _AppDensityTrackState();
}

class _AppDensityTrackState extends State<AppDensityTrack> {
  static const double _trackWidth = 221.0;
  static const double _trackHeight = 13.0;
  static const List<double> _tickLeftOffsets = [10.0, 109.0, 208.0];
  static const double _selectionRingSize = 13.0;
  static const double _selectionDotSize = 9.0;

  static const TextStyle _labelStyle = AppTextStyles.caption;
  static const Color _labelColor = Colors.black;

  double? _dragX;

  int _nearestIndex(double dx) {
    int nearest = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < _tickLeftOffsets.length; i++) {
      final tickCenter = _tickLeftOffsets[i] + 1.5;
      final distance = (dx - tickCenter).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  void _handleDragUpdate(double dx) {
    setState(() => _dragX = dx.clamp(0.0, _trackWidth));
  }

  void _handleDragEnd() {
    if (_dragX != null) {
      widget.onLevelSelected?.call(_nearestIndex(_dragX!));
    }
    setState(() => _dragX = null);
  }

  void _handleTap(double dx) {
    widget.onLevelSelected?.call(_nearestIndex(dx.clamp(0.0, _trackWidth)));
  }

  @override
  Widget build(BuildContext context) {
    final double? circleCenterX = _dragX ??
        (widget.selectedIndex != null
            ? _tickLeftOffsets[widget.selectedIndex!] + 1.5
            : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('여유롭게', style: _labelStyle.copyWith(color: _labelColor)),
          const SizedBox(width: 20.0),
          SizedBox(
            width: _trackWidth,
            height: _trackHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 5.0,
                  child: Container(
                    width: _trackWidth,
                    height: 3.0,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.purple1, AppColors.purple2],
                      ),
                    ),
                  ),
                ),
                for (int i = 0; i < _tickLeftOffsets.length; i++)
                  Positioned(
                    left: _tickLeftOffsets[i],
                    top: 0,
                    child: Container(
                      width: 3.0,
                      height: _trackHeight,
                      color: AppColors.purple2,
                    ),
                  ),
                if (circleCenterX != null)
                  Positioned(
                    left: circleCenterX - _selectionRingSize / 2,
                    top: _trackHeight / 2 - _selectionRingSize / 2,
                    child: Container(
                      width: _selectionRingSize,
                      height: _selectionRingSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purple3, width: 1.0),
                        boxShadow: const [
                          BoxShadow(color: AppColors.purple2, blurRadius: 4.0),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: _selectionDotSize,
                          height: _selectionDotSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple3,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => _handleTap(details.localPosition.dx),
                    onHorizontalDragUpdate: (details) =>
                        _handleDragUpdate(details.localPosition.dx),
                    onHorizontalDragEnd: (_) => _handleDragEnd(),
                    onHorizontalDragCancel: _handleDragEnd,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20.0),
          Text('빽빽하게', style: _labelStyle.copyWith(color: _labelColor)),
        ],
      ),
    );
  }
}

class _DensityTrackDemo extends StatefulWidget {
  const _DensityTrackDemo();

  @override
  State<_DensityTrackDemo> createState() => _DensityTrackDemoState();
}

class _DensityTrackDemoState extends State<_DensityTrackDemo> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return AppDensityTrack(
      selectedIndex: _selected,
      onLevelSelected: (index) => setState(() => _selected = index),
    );
  }
}

@Preview(group: 'haerim', name: 'AppDensityTrack')
Widget appDensityTrackPreview() => const _DensityTrackDemo();