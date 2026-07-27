import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
