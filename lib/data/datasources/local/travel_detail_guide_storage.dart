import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/design_system/app_travel_status.dart';

class TravelDetailGuideStorage {
  const TravelDetailGuideStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _dismissedKeyFor(AppTravelStatus status) =>
      'pozit_travel_detail_guide_dismissed_${status.name}';

  Future<bool> isDismissed(AppTravelStatus status) async {
    final value = await _storage.read(key: _dismissedKeyFor(status));
    return value == 'true';
  }

  Future<void> markDismissed(AppTravelStatus status) {
    return _storage.write(key: _dismissedKeyFor(status), value: 'true');
  }
}
