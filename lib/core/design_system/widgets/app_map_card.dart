import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_images.dart';
import '../app_text_styles.dart';

const Duration _kTransitionDuration = Duration(milliseconds: 260);

const double _kMarkerSize = 16;

const double _kVisitingMarkerSize = 30;
const double _kVisitingIconScale = _kVisitingMarkerSize / 24;

enum MapMarkerStatus { visited, visiting, notVisited }

class MapMarker {
  const MapMarker({
    required this.position,
    required this.label,
    this.status = MapMarkerStatus.notVisited,
    this.isSelected = false,
  });

  final LatLng position;
  final String label;
  final MapMarkerStatus status;

  final bool isSelected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapMarker &&
        other.position == position &&
        other.label == label &&
        other.status == status &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => Object.hash(position, label, status, isSelected);
}

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

class AppMapView extends StatefulWidget {
  const AppMapView({
    super.key,
    this.markers = const [],
    this.onMarkerTap,
    this.enableGestures = false,
    this.fitVisibleFraction = 1.0,
  }) : assert(
         fitVisibleFraction > 0 && fitVisibleFraction <= 1,
         'fitVisibleFraction은 0보다 크고 1 이하여야 합니다.',
       );

  final List<MapMarker> markers;

  final ValueChanged<int>? onMarkerTap;

  final bool enableGestures;

  final double fitVisibleFraction;

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  final Map<(MapMarkerStatus, bool), Future<PoiStyle>> _styleCache = {};

  KakaoMapController? _controller;
  List<Poi> _pois = const [];
  List<BaseRoute> _routes = const [];
  bool _hasError = false;
  int _renderGeneration = 0;

  Future<PoiStyle> _styleFor(MapMarkerStatus status, bool isSelected) {
    final key = (status, isSelected);
    return _styleCache.putIfAbsent(key, () => _buildStyle(status, isSelected));
  }

  static Future<PoiStyle> _buildStyle(
    MapMarkerStatus status,
    bool isSelected,
  ) async {
    if (status == MapMarkerStatus.visiting) {
      return _buildVisitingStyle(isSelected);
    }

    final isVisited = status == MapMarkerStatus.visited;

    final borderColor = isSelected
        ? AppColors.purple3
        : (isVisited ? AppColors.purple3 : AppColors.gray4);
    final borderWidth = isSelected ? 1.5 : (isVisited ? 0.5 : 1.0);

    final icon = await KImage.fromWidget(
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isVisited ? AppColors.purple2 : AppColors.gray2,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
      ),
      const Size.square(_kMarkerSize),
    );
    return PoiStyle(
      icon: icon,

      anchor: const KPoint(0.5, 0.5),

      applyDpScale: false,
    );
  }

  static Future<PoiStyle> _buildVisitingStyle(bool isSelected) async {
    final icon = await KImage.fromWidget(
      Container(
        width: _kVisitingMarkerSize,
        height: _kVisitingMarkerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: isSelected
              ? Border.all(color: AppColors.purple3, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(color: Color(0x669FA1FF), blurRadius: 4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 3.999, 3.066, 3.44) *
              _kVisitingIconScale,
          child: Image.asset(AppImages.posongVisiting),
        ),
      ),
      const Size.square(_kVisitingMarkerSize),
    );
    return PoiStyle(
      icon: icon,
      anchor: const KPoint(0.5, 0.5),
      applyDpScale: false,
    );
  }

  void _handleMapReady(KakaoMapController controller) {
    _controller = controller;
    if (!widget.enableGestures) {
      for (final gesture in GestureType.values) {
        if (gesture == GestureType.unknown) continue;
        controller.setGesture(gesture, false);
      }
    }
    _renderOverlays();
  }

  void _handleMapError(Object error) {
    if (!mounted) return;
    setState(() => _hasError = true);
  }

  void _handleRetry() {
    setState(() {
      _hasError = false;
      _controller = null;
      _pois = const [];
      _routes = const [];
    });
  }

  Future<void> _renderOverlays() async {
    final controller = _controller;
    if (controller == null) return;
    final generation = ++_renderGeneration;
    bool isStale() => !mounted || generation != _renderGeneration;

    await _renderMarkers(controller, generation);
    if (isStale()) return;
    await _renderRoute(controller, generation);
    if (isStale()) return;

    final points = widget.markers.map((m) => m.position).toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      await controller.moveCamera(
        CameraUpdate.newCenterPosition(points.first, zoomLevel: 16),
      );
    } else {
      await controller.moveCamera(
        CameraUpdate.fitMapPoints(points, padding: 80),
      );
    }
    if (isStale()) return;
    await _biasCameraTowardVisibleArea(controller, generation);
  }

  Future<void> _biasCameraTowardVisibleArea(
    KakaoMapController controller,
    int generation,
  ) async {
    final fraction = widget.fitVisibleFraction;
    if (fraction >= 1.0 || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted || generation != _renderGeneration) return;

    final size = context.size;
    if (size == null) return;

    final dpr = MediaQuery.of(context).devicePixelRatio;

    final deltaY = size.height / 2 * (1 - fraction);
    final queryX = (size.width / 2 * dpr).round();
    final queryY = ((size.height / 2 + deltaY) * dpr).round();
    final target = await controller.fromScreenPoint(queryX, queryY);
    if (target == null || !mounted || generation != _renderGeneration) return;
    await controller.moveCamera(CameraUpdate.newCenterPosition(target));
  }

  Future<void> _renderMarkers(
    KakaoMapController controller,
    int generation,
  ) async {
    bool isStale() => !mounted || generation != _renderGeneration;
    final layer = controller.labelLayer;

    for (final poi in _pois) {
      await layer.removePoi(poi);
      if (isStale()) return;
    }
    _pois = const [];

    if (widget.markers.isEmpty) return;

    final onMarkerTap = widget.onMarkerTap;
    final newPois = <Poi>[];
    for (var i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      if (isStale()) return;
      void Function()? onClick;
      if (onMarkerTap != null) {
        onClick = () => onMarkerTap(i);
      }
      final poi = await _addPoiWithRetry(layer, marker, style, onClick);
      if (isStale()) return;
      if (poi != null) newPois.add(poi);
    }
    if (isStale()) return;
    _pois = newPois;
  }

  Future<Poi?> _addPoiWithRetry(
    LabelController layer,
    MapMarker marker,
    PoiStyle style,
    void Function()? onClick,
  ) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await layer.addPoi(
          marker.position,
          style: style,
          onClick: onClick,
        );
      } on OverlayRegistrationFailedError {
        if (attempt == maxAttempts) {
          debugPrint('마커(${marker.label}) 추가 실패: 재시도 초과');
          return null;
        }
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }
    return null;
  }

  Future<void> _renderRoute(
    KakaoMapController controller,
    int generation,
  ) async {
    bool isStale() => !mounted || generation != _renderGeneration;
    final layer = controller.routeLayer;

    for (final route in _routes) {
      await layer.removeRoute(route);
      if (isStale()) return;
    }
    _routes = const [];

    if (widget.markers.length < 2) return;

    final segmentCount = widget.markers.length - 1;
    final option = MultipleRouteOption(null);
    for (var i = 0; i < segmentCount; i++) {
      final t = segmentCount == 1 ? 1.0 : i / (segmentCount - 1);
      final color = Color.lerp(AppColors.purple2, AppColors.purple3, t)!;

      option.addRouteStyle(RouteStyle(color, 1));
      option.addRouteWithIndex(
        [widget.markers[i].position, widget.markers[i + 1].position],
        i,
      );
    }
    final route = await layer.addMultipleRoute(option);
    if (isStale()) return;
    _routes = [route];
  }

  @override
  void didUpdateWidget(covariant AppMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.markers, widget.markers)) return;

    if (_samePositions(oldWidget.markers, widget.markers)) {
      _updateMarkerStyles();
    } else {
      _renderOverlays();
    }
  }

  bool _samePositions(List<MapMarker> a, List<MapMarker> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].position != b[i].position) return false;
    }
    return true;
  }

  Future<void> _updateMarkerStyles() async {
    final generation = ++_renderGeneration;
    bool isStale() => !mounted || generation != _renderGeneration;

    for (var i = 0; i < widget.markers.length && i < _pois.length; i++) {
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      if (isStale()) return;
      await _pois[i].changeStyles(style);
      if (isStale()) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ColoredBox(
        color: AppColors.gray2,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '지도를 불러오지 못했어요',
                style: TextStyle(color: AppColors.gray5),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _handleRetry,
                child: Text(
                  '다시 시도',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return KakaoMap(
      option: KakaoMapOption(
        position: widget.markers.isNotEmpty
            ? widget.markers.first.position
            : const KakaoMapOption().position,
        zoomLevel: 16,
      ),

      forceGesture: widget.enableGestures,
      onMapReady: _handleMapReady,
      onMapError: _handleMapError,
    );
  }
}

class AppMapCard extends StatelessWidget {
  const AppMapCard({
    super.key,
    required this.title,
    this.markers = const [],
    this.currentPage = 0,
    this.pageCount = 4,
    this.onCourseTap,
    this.courseButtonKey,
    this.mapKey,
  }) : assert(pageCount > 0, 'pageCount는 1 이상이어야 합니다.'),
       assert(
         currentPage >= 0 && currentPage < pageCount,
         'currentPage는 pageCount 범위 안이어야 합니다.',
       );

  final String title;
  final List<MapMarker> markers;
  final int currentPage;
  final int pageCount;
  final VoidCallback? onCourseTap;

  final Key? courseButtonKey;

  final Key? mapKey;

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
                  key: mapKey,
                  aspectRatio: 319 / 156,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppMapView(markers: markers),
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
            child: _CourseAction(key: courseButtonKey, onTap: onCourseTap),
          ),
        ],
      ),
    );
  }
}

class _CourseAction extends StatelessWidget {
  const _CourseAction({super.key, required this.onTap});

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

    final alignmentX = pageCount == 1
        ? 0.0
        : -1 + 2 * (currentPage / (pageCount - 1));

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
          child: AppMapCard(
            title: '연꽃단지',
            markers: [
              MapMarker(
                position: LatLng(37.402005, 127.108621),
                label: '연꽃단지',
                status: MapMarkerStatus.visited,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
