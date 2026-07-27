import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 여행 상세 화면 사용자 설명(코치마크)을 "다신 보지 않기"로 껐는지 여부를
/// 기기에 저장합니다. 껐다는 기록이 없으면(처음이거나 아직 안 눌렀으면)
/// 여행 전/중 상태로 여행 상세에 들어갈 때마다 매번 다시 보여줍니다.
class TravelDetailGuideStorage {
  const TravelDetailGuideStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _dismissedKey = 'pozit_travel_detail_guide_dismissed';

  final FlutterSecureStorage _storage;

  Future<bool> isDismissed() async {
    final value = await _storage.read(key: _dismissedKey);
    return value == 'true';
  }

  Future<void> markDismissed() {
    return _storage.write(key: _dismissedKey, value: 'true');
  }
}
