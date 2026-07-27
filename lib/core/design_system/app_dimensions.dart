/// 앱 전역에서 공통으로 사용하는 치수 토큰입니다.
abstract final class AppDimensions {
  /// 한 줄 입력 UI의 기본 최소 높이입니다.
  static const double inputMinHeight = 48;

  /// 터치 가능한 UI가 보장해야 하는 최소 크기입니다.
  static const double minimumTapTargetSize = 48;

  /// 하단 안전 영역 위에 추가로 확보하는 여백입니다.
  static const double bottomNavigationSpacing = 10;
}
