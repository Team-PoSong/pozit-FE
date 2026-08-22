import 'package:flutter/foundation.dart';

import '../../models/saved_travel_model.dart';

/// 저장한 여행을 앱 안에서 공유하는 임시 저장소입니다.
class TravelStore {
  TravelStore._();

  static final TravelStore instance = TravelStore._();

  final ValueNotifier<List<SavedTravelModel>> travels =
      ValueNotifier<List<SavedTravelModel>>(const []);

  /// 여행을 저장하고 홈 화면에 즉시 반영합니다.
  void save(SavedTravelModel travel) {
    final current = [...travels.value]
      ..removeWhere((item) => item.id == travel.id)
      ..insert(0, travel);
    travels.value = List.unmodifiable(current);
  }

  void replaceAll(List<SavedTravelModel> items) {
    travels.value = List.unmodifiable(items);
  }
}
