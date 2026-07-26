import 'dart:async';

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

// travel_status.dart의 _CompletedItem/_NotVisitedItem과 동일한 지름(16)입니다.
const double _kMarkerSize = 16;
// travel_status.dart의 _VisitingItem을 30x30으로 확대한 값입니다(원본 24).
const double _kVisitingMarkerSize = 30;
const double _kVisitingIconScale = _kVisitingMarkerSize / 24;

/// 지도 위 마커(핀)의 방문 상태입니다.
enum MapMarkerStatus { visited, visiting, notVisited }

/// 지도에 찍을 마커 한 개(여행지 하나)를 나타냅니다.
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

  /// 지도 카드 제목(현재 보고 있는 코스의 첫 번째 여행지)과 같은 마커인지
  /// 여부입니다. true면 Purple3/1.5px 테두리로 강조됩니다.
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

/// 카카오맵 위에 [markers]를 그리는, 카드 장식이 없는 순수 지도 뷰입니다.
///
/// [AppMapCard](카드형)와 코스 보기 화면(전체 화면형)이 마커·동선 렌더링
/// 로직을 공유하기 위한 하위 위젯입니다. 부모가 준 영역을 그대로 채우므로,
/// 카드처럼 고정 비율이 필요하면 [AspectRatio] 등으로 바깥에서 감싸야 합니다.
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

  /// 마커(원)를 탭했을 때, [markers] 안에서의 인덱스와 함께 호출됩니다.
  final ValueChanged<int>? onMarkerTap;

  /// 손가락으로 지도를 직접 이동/확대/회전할 수 있게 할지 여부입니다.
  ///
  /// [AppMapCard]처럼 좌우 스와이프로 코스를 전환하는 용도라면 지도 자체
  /// 제스처와 충돌하므로 꺼둡니다(기본값). 코스 보기 화면처럼 지도 자체가
  /// 화면 전체를 채우는 경우에는 true로 켜서 지도를 직접 움직일 수 있게
  /// 합니다.
  final bool enableGestures;

  /// 마커에 자동으로 카메라를 맞출 때(fitMapPoints), 실제로 마커가 들어와야
  /// 하는 위쪽 영역의 비율입니다.
  ///
  /// 이 지도 위에 바텀 시트 등으로 아래쪽 일부가 가려지는 경우, 기본값
  /// 1.0(화면 전체에 맞춤)을 쓰면 마커들이 화면 정중앙 근처, 즉 가려지는
  /// 영역 언저리에 몰릴 수 있습니다. 예를 들어 아래쪽 50%가 가려진다면
  /// 0.5를 넘겨서, 마커들이 위쪽 절반 안에 들어오도록 카메라를 맞춥니다.
  final double fitVisibleFraction;

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  // 마커 아이콘은 (상태, 선택 여부) 조합별로 몇 종류뿐이라, 앱 전체에서 한 번만
  // 생성해 재사용합니다. KImage.fromWidget이 비동기라 Future로 캐싱합니다.
  static final Map<(MapMarkerStatus, bool), Future<PoiStyle>> _styleCache = {};

  KakaoMapController? _controller;
  List<Poi> _pois = const [];
  List<BaseRoute> _routes = const [];
  bool _hasError = false;

  static Future<PoiStyle> _styleFor(MapMarkerStatus status, bool isSelected) {
    final key = (status, isSelected);
    return _styleCache.putIfAbsent(key, () => _buildStyle(status, isSelected));
  }

  static Future<PoiStyle> _buildStyle(
    MapMarkerStatus status,
    bool isSelected,
  ) async {
    // '방문중'은 travel_status.dart의 _VisitingItem 스타일(흰 원 + 그림자 +
    // 포솜 아이콘)을 그대로 가져오되 30x30으로 키운 것입니다. 선택된
    // 경우에는 다른 상태와 동일하게 Purple3/1.5px 테두리를 추가합니다.
    if (status == MapMarkerStatus.visiting) {
      return _buildVisitingStyle(isSelected);
    }

    final isVisited = status == MapMarkerStatus.visited;
    // travel_status.dart의 _CompletedItem(purple2/purple3, 0.5) ·
    // _NotVisitedItem(gray2/gray4, 1.0)과 동일한 색·두께이며, 선택된 마커만
    // Purple3/1.5px 테두리로 덮어씁니다.
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
      // 원의 중심이 곧 좌표가 되어야 두 마커를 잇는 선이 원 중심끼리
      // 연결됩니다(기본 anchor는 (0.5, 1.0), 즉 아이콘 하단 중앙입니다).
      anchor: const KPoint(0.5, 0.5),
      // KImage.fromWidget이 이미 기기 배율에 맞춰 렌더링하므로, 여기서
      // 다시 dp 배율을 적용하면 실제 크기가 지정한 16x16보다 커집니다.
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
      // 지도 카드는 좌우로 스와이프해서 코스를 전환하는 용도라, 지도 자체를
      // 손가락으로 이동/확대/회전할 수 있으면 그 제스처와 충돌합니다. 지도의
      // 모든 제스처를 꺼서 카메라는 오직 코드([_renderOverlays])로만
      // 움직이게 합니다.
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

  Future<void> _renderOverlays() async {
    final controller = _controller;
    if (controller == null) return;

    await _renderMarkers(controller);
    await _renderRoute(controller);

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
    await _biasCameraTowardVisibleArea(controller);
  }

  /// [widget.fitVisibleFraction]이 1.0 미만이면(예: 바텀 시트가 화면 아래쪽
  /// 일부를 가리는 경우), 지금 화면 정중앙에 있는 지점이 화면 전체가 아니라
  /// 위쪽 [fitVisibleFraction] 영역의 세로 중앙에 오도록 카메라를 다시
  /// 옮깁니다. fitMapPoints로 맞춘 직후는 물론, 마커를 눌러 포커스로
  /// 이동시킨 직후에도 똑같이 씁니다.
  ///
  /// 위/경도 범위를 직접 계산해 미리 늘리는 방식은 마커들이 같은 위도(정
  /// 동서 방향)에 있는 경우 기준으로 삼을 범위가 없어 어긋났습니다. 대신
  /// 방금 잡힌 화면 좌표 기준으로 "지금 화면 중앙에 있는 지점"이 대신
  /// "보이는 영역의 세로 중앙"에 오도록, 실제 화면 픽셀 좌표를 위/경도로
  /// 변환해주는 [KakaoMapController.fromScreenPoint]로 옮길 지점을 구합니다.
  Future<void> _biasCameraTowardVisibleArea(
    KakaoMapController controller,
  ) async {
    final fraction = widget.fitVisibleFraction;
    if (fraction >= 1.0 || !mounted) return;

    // moveCamera의 Future는 네이티브가 fitMapPoints/newCenterPosition의
    // 실제 카메라 이동 계산을 마치기 전에 먼저 완료되는 경우가 있어(실기
    // 로그로 확인: fromScreenPoint 호출이 fitMapPoints보다 먼저 처리됨),
    // 곧바로 fromScreenPoint를 호출하면 이동 전 위치 기준으로 좌표가
    // 계산됩니다. 카메라가 실제로 자리잡을 시간을 짧게 확보합니다.
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final size = context.size;
    if (size == null) return;
    // fromScreenPoint는 Flutter의 논리적 픽셀이 아니라 기기의 실제(물리)
    // 픽셀 좌표를 기대합니다(실기 로그로 확인: 화면 중앙에서 세로로만
    // 옮긴 논리 좌표를 넘겼는데도 위도·경도가 함께 크게 어긋나는 결과가
    // 나왔고, devicePixelRatio를 곱해 물리 픽셀로 보정하니 세로로만
    // 어긋난 결과가 나왔습니다).
    final dpr = MediaQuery.of(context).devicePixelRatio;

    // 화면 정중앙에 있던 지점이 "보이는 영역의 세로 중앙"에 오려면, 카메라
    // 중심을 지금보다 이만큼(픽셀) 남쪽에 있던 지점으로 옮겨야 합니다.
    final deltaY = size.height / 2 * (1 - fraction);
    final queryX = (size.width / 2 * dpr).round();
    final queryY = ((size.height / 2 + deltaY) * dpr).round();
    final target = await controller.fromScreenPoint(queryX, queryY);
    if (target == null || !mounted) return;
    await controller.moveCamera(CameraUpdate.newCenterPosition(target));
  }

  /// 마커를 눌렀을 때 그 위치로 카메라를 이동해 포커스합니다.
  Future<void> _focusOnMarker(
    KakaoMapController controller,
    LatLng position,
  ) async {
    await controller.moveCamera(
      CameraUpdate.newCenterPosition(position, zoomLevel: 16),
      animation: const CameraAnimation(300),
    );
    await _biasCameraTowardVisibleArea(controller);
  }

  Future<void> _renderMarkers(KakaoMapController controller) async {
    final layer = controller.labelLayer;

    for (final poi in _pois) {
      await layer.removePoi(poi);
    }
    _pois = const [];

    if (widget.markers.isEmpty) return;

    final onMarkerTap = widget.onMarkerTap;
    final newPois = <Poi>[];
    for (var i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      void Function()? onClick;
      if (onMarkerTap != null) {
        onClick = () {
          // 마커를 누르면 그 위치로 카메라가 이동해 포커스됩니다.
          unawaited(_focusOnMarker(controller, marker.position));
          onMarkerTap(i);
        };
      }
      final poi = await _addPoiWithRetry(layer, marker, style, onClick);
      if (poi != null) newPois.add(poi);
    }
    if (!mounted) return;
    _pois = newPois;
  }

  // kakao_map_sdk 1.2.6에는, 스타일을 등록한 직후 곧바로 그 스타일로 Poi를
  // 추가하면 네이티브 쪽에서 아직 스타일 등록이 끝나지 않은 것으로 보여
  // "LabelStyles is null"과 함께 OverlayRegistrationFailedError가 발생하는
  // 레이스 컨디션이 있습니다(실기 로그로 확인. 특히 여러 마커를 한 번에 찍는
  // 화면 진입 직후에 재현됩니다). 짧게 기다렸다가 다시 시도하면 대부분
  // 통과하고, 그래도 계속 실패하면 그 마커만 건너뛰어 나머지 마커·동선
  // 렌더링에는 영향이 없게 합니다.
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

  // 여행 전/중 상관없이(사용자 확인 완료) 코스 순서를 Purple2→Purple3
  // 그라데이션 선으로 잇습니다. RouteStyle은 단색만 지원해서, 구간을 나눠
  // 각 구간 색을 보간하는 방식으로 그라데이션처럼 보이게 합니다.
  //
  // 참고: 처음엔 ShapeController.addPolylineShape(단일 Polyline)로
  // 구현했으나 네이티브에서 "PolylineStylesSet create failure. PolylineStyles
  // cannot be null or empty." 오류가 반복적으로 발생했습니다(Dart 예외로는
  // 드러나지 않고 네이티브 로그에만 남는 문제라 실기 로그 확인 후 발견).
  // 대신 여러 지점을 잇는 용도로 설계된 MultipleRoute API로 바꾸니
  // 문제없이 동작합니다.
  Future<void> _renderRoute(KakaoMapController controller) async {
    final layer = controller.routeLayer;

    for (final route in _routes) {
      await layer.removeRoute(route);
    }
    _routes = const [];

    if (widget.markers.length < 2) return;

    final segmentCount = widget.markers.length - 1;
    final option = MultipleRouteOption(null);
    for (var i = 0; i < segmentCount; i++) {
      final t = segmentCount == 1 ? 1.0 : i / (segmentCount - 1);
      final color = Color.lerp(AppColors.purple2, AppColors.purple3, t)!;
      // kakao_map_sdk 1.2.6의 MultipleRouteOption.addRouteWithStyle()에는
      // styles.add(style) 직후 styles.length(추가 후 길이)를 styleIndex로
      // 쓰는 off-by-one 버그가 있어(0이 아닌 1부터 시작), 세그먼트가 2개
      // 이상이면 실제 styles 배열 범위를 벗어나 RangeError가 납니다.
      // addRouteStyle + addRouteWithIndex로 직접 0-based 인덱스를 넣어
      // 우회합니다.
      option.addRouteStyle(RouteStyle(color, 1));
      option.addRouteWithIndex(
        [widget.markers[i].position, widget.markers[i + 1].position],
        i,
      );
    }
    final route = await layer.addMultipleRoute(option);
    if (!mounted) return;
    _routes = [route];
  }

  @override
  void didUpdateWidget(covariant AppMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.markers, widget.markers)) return;

    if (_samePositions(oldWidget.markers, widget.markers)) {
      // 좌표 집합(=원과 연결선의 모양)은 그대로고 상태/선택 표시만 바뀐
      // 경우입니다(예: 코스 스와이프로 강조 원만 이동). 전체를 지웠다가
      // 다시 그리면 그 찰나에 원들이 사라져, 계속 떠 있던 연결선이 잠깐
      // 위로 비쳐 보이는 깜빡임이 생겼습니다. 해당 마커만 제자리에서
      // 스타일을 바꿔치기하고, 선은 손대지 않습니다.
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
    for (var i = 0; i < widget.markers.length && i < _pois.length; i++) {
      final marker = widget.markers[i];
      final style = await _styleFor(marker.status, marker.isSelected);
      await _pois[i].changeStyles(style);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const ColoredBox(
        color: AppColors.gray2,
        child: Center(
          child: Text(
            '지도를 불러오지 못했어요',
            style: TextStyle(color: AppColors.gray5),
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
      // enableGestures가 false면(카드형) 지도 자체 제스처도 꺼둔 상태이므로,
      // 이 화면을 감싼 GestureDetector(코스 스와이프 등)가 터치를 우선
      // 받을 수 있도록 지도가 제스처를 가로채지 않게 합니다. enableGestures가
      // true면(전체 화면형) 반대로 지도가 직접 제스처를 받아야 손가락으로
      // 움직일 수 있습니다.
      forceGesture: widget.enableGestures,
      onMapReady: _handleMapReady,
      onMapError: _handleMapError,
    );
  }
}

/// 여행 코스의 지도를 보여주는 카드입니다.
///
/// [markers]에 담긴 위/경도·방문 상태를 실제 카카오맵 위에 마커로 표시합니다.
/// 실제 마커·동선 렌더링은 [AppMapView]에 위임합니다.
class AppMapCard extends StatelessWidget {
  const AppMapCard({
    super.key,
    required this.title,
    this.markers = const [],
    this.currentPage = 0,
    this.pageCount = 4,
    this.onCourseTap,
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
                    child: AppMapView(markers: markers),
                  ),
                ),
                const SizedBox(height: 10),
                _PageIndicator(currentPage: currentPage, pageCount: pageCount),
              ],
            ),
          ),
          Positioned(top: 2, right: 12, child: _CourseAction(onTap: onCourseTap)),
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
