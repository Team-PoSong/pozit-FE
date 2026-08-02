import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_images.dart';
import '../app_text_styles.dart';

const Duration _kTransitionDuration = Duration(milliseconds: 260);

const int _kDefaultZoomLevel = 15;
const int _kCardSingleMarkerZoomLevel = 11;
const int _kFitMapPointsPadding = 20;
const int _kCardFitMapPointsPadding = 100;

const double _kMarkerSize = 16;

const double _kVisitingMarkerSize = 30;
const double _kVisitingIconScale = _kVisitingMarkerSize / 24;

const double _kUserLocationMarkerSize = 16;

const String _kPoiLabelLayerId = 'app_map_poi_layer';

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

class AppMapViewController {
  _AppMapViewState? _state;

  Future<void> moveCamera(LatLng position, {int? zoomLevel}) async {
    await _state?._moveCameraTo(position, zoomLevel: zoomLevel);
  }
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
    this.userLocation,
    this.controller,
    this.singleMarkerZoomLevel = _kDefaultZoomLevel,
    this.fitPointsPadding = _kFitMapPointsPadding,
  }) : assert(
         fitVisibleFraction > 0 && fitVisibleFraction <= 1,
         'fitVisibleFraction은 0보다 크고 1 이하여야 합니다.',
       );

  final List<MapMarker> markers;

  final ValueChanged<int>? onMarkerTap;

  final bool enableGestures;

  final double fitVisibleFraction;

  final LatLng? userLocation;

  final AppMapViewController? controller;

  final int singleMarkerZoomLevel;

  final int fitPointsPadding;

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  final Map<(MapMarkerStatus, bool), Future<PoiStyle>> _styleCache = {};

  KakaoMapController? _controller;
  LabelController? _poiLayer;
  /// widget.markers와 동일한 인덱스로 정렬됩니다. 등록에 실패한 자리는 null로 남습니다.
  List<Poi?> _pois = const [];
  List<BaseRoute> _routes = const [];
  bool _hasError = false;
  bool _hasSettledCamera = false;
  int _renderGeneration = 0;

  Future<void> _poiOperationQueue = Future<void>.value();

  Poi? _userLocationPoi;
  Future<PoiStyle>? _userLocationStyleFuture;
  bool _isAddingUserLocationPoi = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant AppMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    final userLocationChanged = oldWidget.userLocation != widget.userLocation;
    final missingUserLocationPoi =
        widget.userLocation != null && _userLocationPoi == null;
    if (userLocationChanged || missingUserLocationPoi) {
      _renderUserLocation();
    }

    if (listEquals(oldWidget.markers, widget.markers)) return;

    if (_samePositions(oldWidget.markers, widget.markers)) {
      _updateMarkerStyles();
    } else {
      _renderOverlays();
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    _invalidateMapState();
    super.dispose();
  }

  /// 진행 중인 렌더링 작업이 다음 체크포인트에서 스스로 중단하도록
  /// generation을 무효화하고, 더 이상 유효하지 않은 컨트롤러 참조를 해제합니다.
  /// 단, 이미 네이티브로 전달된 호출 자체를 취소하지는 못합니다.
  void _invalidateMapState() {
    _renderGeneration++;
    _controller = null;
    _poiLayer = null;
  }

  /// POI 추가·삭제·스타일 변경 작업이 동시에 네이티브로 전달되지 않도록
  /// 하나의 큐를 통해 순차적으로 실행합니다.
  Future<void> _enqueuePoiOperation(Future<void> Function() operation) {
    final result = _poiOperationQueue.then((_) => operation()).catchError((
      error,
    ) {
      debugPrint('POI 작업 실패: $error');
    });
    _poiOperationQueue = result;
    return result;
  }

  Future<void> _moveCameraTo(LatLng position, {int? zoomLevel}) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.moveCamera(
      CameraUpdate.newCenterPosition(
        position,
        zoomLevel: zoomLevel ?? _kDefaultZoomLevel,
      ),
    );
  }

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

  Future<void> _handleMapReady(KakaoMapController controller) async {
    _controller = controller;
    if (!widget.enableGestures) {
      for (final gesture in GestureType.values) {
        if (gesture == GestureType.unknown) continue;
        controller.setGesture(gesture, false);
      }
    }
    try {
      // iOS는 기본 라벨 레이어가 네이티브에 생성되어 있지 않아 강제 언래핑 크래시(SIGTRAP)로
      // 이어지므로 명시적으로 레이어를 만들어야 합니다. 반대로 Android 플러그인은
      // createLabelLayer 처리 시 대상 레이어를 먼저 조회하려다 존재하지 않으면 그 자리에서
      // NPE를 던지는 버그가 있어, 이미 네이티브에 존재하는 기본 레이어를 그대로 사용합니다.
      final poiLayer = Platform.isIOS
          ? await controller.addLabelLayer(_kPoiLabelLayerId)
          : controller.labelLayer;
      if (!mounted || _controller != controller) return;
      _poiLayer = poiLayer;
      await _renderOverlays();
      if (!mounted) return;
      await _renderUserLocation();
    } catch (error) {
      debugPrint('지도 초기화 실패: $error');
    } finally {
      if (mounted && !_hasSettledCamera) {
        setState(() => _hasSettledCamera = true);
      }
    }
  }

  void _handleMapError(Object error) {
    if (!mounted) return;
    _invalidateMapState();
    setState(() => _hasError = true);
  }

  void _handleRetry() {
    _invalidateMapState();
    setState(() {
      _hasError = false;
      _pois = const [];
      _routes = const [];
    });
  }

  Future<void> _renderOverlays() {
    final controller = _controller;
    if (controller == null) return Future.value();
    final generation = ++_renderGeneration;
    return _enqueuePoiOperation(() => _runRenderOverlays(controller, generation));
  }

  Future<void> _runRenderOverlays(
    KakaoMapController controller,
    int generation,
  ) async {
    bool isStale() => !mounted || generation != _renderGeneration;
    if (isStale()) return;

    await _renderMarkers(controller, generation);
    if (isStale()) return;
    await _renderRoute(controller, generation);
    if (isStale()) return;

    await _fitCamera(controller, generation);
  }

  Future<void> _fitCamera(KakaoMapController controller, int generation) async {
    bool isStale() => !mounted || generation != _renderGeneration;

    final points = widget.markers.map((m) => m.position).toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      await controller.moveCamera(
        CameraUpdate.newCenterPosition(
          points.first,
          zoomLevel: widget.singleMarkerZoomLevel,
        ),
      );
    } else {
      await controller.moveCamera(
        CameraUpdate.fitMapPoints(points, padding: widget.fitPointsPadding),
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

    final scale = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;

    final deltaY = size.height / 2 * (1 - fraction);
    final queryX = (size.width / 2 * scale).round();
    final queryY = ((size.height / 2 + deltaY) * scale).round();
    final target = await controller.fromScreenPoint(queryX, queryY);
    if (target == null || !mounted || generation != _renderGeneration) return;

    final currentZoomLevel = (await controller.getCameraPosition()).zoomLevel;
    if (!mounted || generation != _renderGeneration) return;

    final zoomAdjustment = (math.log(1 / fraction) / math.log(2)).ceil();
    final adjustedZoomLevel = currentZoomLevel - zoomAdjustment;

    await controller.moveCamera(
      CameraUpdate.newCenterPosition(target, zoomLevel: adjustedZoomLevel),
    );
  }

  Future<void> _renderMarkers(
    KakaoMapController controller,
    int generation,
  ) async {
    bool isStale() => !mounted || generation != _renderGeneration;
    final layer = _poiLayer;
    if (layer == null) return;

    for (var i = 0; i < _pois.length; i++) {
      final poi = _pois[i];
      if (poi != null) {
        await layer.removePoi(poi);
        _pois[i] = null;
      }
      if (isStale()) return;
    }
    _pois = const [];

    if (widget.markers.isEmpty) return;

    final onMarkerTap = widget.onMarkerTap;
    final newPois = List<Poi?>.filled(widget.markers.length, null);
    _pois = newPois;
    for (var i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      if (isStale()) return;
      void Function()? onClick;
      if (onMarkerTap != null) {
        onClick = () => onMarkerTap(i);
      }
      final poi = await _addPoiWithRetry(
        layer,
        marker.position,
        style,
        onClick: onClick,
        label: '마커(${marker.label})',
      );
      if (isStale()) return;
      newPois[i] = poi;
    }
  }

  Future<Poi?> _addPoiWithRetry(
    LabelController layer,
    LatLng position,
    PoiStyle style, {
    void Function()? onClick,
    String label = '마커',
  }) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await layer.addPoi(position, style: style, onClick: onClick);
      } on OverlayRegistrationFailedError {
        if (attempt == maxAttempts) {
          debugPrint('$label 추가 실패: 재시도 초과');
          return null;
        }
      } on PlatformException {
        // 레이어 생성 직후에는 네이티브 쪽에서 아직 레이어가 조회되지 않아
        // 일시적으로 실패할 수 있어 재시도합니다.
        if (attempt == maxAttempts) {
          debugPrint('$label 추가 실패: 재시도 초과');
          return null;
        }
      }
      await Future.delayed(const Duration(milliseconds: 80));
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

  Future<void> _renderUserLocation() {
    return _enqueuePoiOperation(_runRenderUserLocation);
  }

  Future<void> _runRenderUserLocation() async {
    final layer = _poiLayer;
    if (layer == null) return;

    final location = widget.userLocation;
    if (location == null) {
      final poi = _userLocationPoi;
      if (poi != null) {
        _userLocationPoi = null;
        await layer.removePoi(poi);
      }
      return;
    }

    final existing = _userLocationPoi;
    if (existing != null) {
      await existing.move(location);
      return;
    }

    if (_isAddingUserLocationPoi) return;
    _isAddingUserLocationPoi = true;
    try {
      final style = await (_userLocationStyleFuture ??= _buildUserLocationStyle());
      if (!mounted) return;
      final latestLocation = widget.userLocation;
      if (latestLocation == null) return;
      _userLocationPoi = await _addPoiWithRetry(
        layer,
        latestLocation,
        style,
        label: '내 위치 마커',
      );
    } finally {
      _isAddingUserLocationPoi = false;
    }
  }

  static Future<PoiStyle> _buildUserLocationStyle() async {
    final icon = await KImage.fromWidget(
      SvgPicture.asset(
        AppIcons.userLocation,
        width: _kUserLocationMarkerSize,
        height: _kUserLocationMarkerSize,
      ),
      const Size.square(_kUserLocationMarkerSize),
    );
    return PoiStyle(icon: icon, anchor: const KPoint(0.5, 0.5), applyDpScale: false);
  }

  bool _samePositions(List<MapMarker> a, List<MapMarker> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].position != b[i].position) return false;
    }
    return true;
  }

  Future<void> _updateMarkerStyles() {
    final generation = ++_renderGeneration;
    return _enqueuePoiOperation(() => _runUpdateMarkerStyles(generation));
  }

  Future<void> _runUpdateMarkerStyles(int generation) async {
    bool isStale() => !mounted || generation != _renderGeneration;
    if (isStale()) return;

    for (var i = 0; i < widget.markers.length && i < _pois.length; i++) {
      final poi = _pois[i];
      if (poi == null) continue;
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      if (isStale()) return;
      await poi.changeStyles(style);
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

    return Stack(
      fit: StackFit.expand,
      children: [
        KakaoMap(
          option: KakaoMapOption(
            position: widget.markers.isNotEmpty
                ? widget.markers.first.position
                : const KakaoMapOption().position,
            zoomLevel: _kDefaultZoomLevel,
          ),

          forceGesture: widget.enableGestures,
          onMapReady: _handleMapReady,
          onMapError: _handleMapError,
        ),
        if (!_hasSettledCamera) const ColoredBox(color: AppColors.gray2),
      ],
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
                    child: AppMapView(
                      markers: markers,
                      singleMarkerZoomLevel: _kCardSingleMarkerZoomLevel,
                      fitPointsPadding: _kCardFitMapPointsPadding,
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
