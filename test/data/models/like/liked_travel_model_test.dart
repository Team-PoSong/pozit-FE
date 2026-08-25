import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/like/liked_travel_model.dart';

Map<String, dynamic> _travelJson(String status) => {
  'travelId': 1,
  'title': '공개 여행',
  'destination': '서울',
  'startDate': '2026-08-24',
  'endDate': '2026-08-25',
  'status': status,
  'isPublic': true,
  'backgroundImageUrl': '',
  'completionRate': 0,
  'tags': <String>[],
  'leaderNickname': '포송',
  'memberCount': 1,
  'likeCount': 0,
  'isLiked': false,
};

void main() {
  for (final entry in {
    'UPCOMING': AppTravelStatus.upcoming,
    'IN_PROGRESS': AppTravelStatus.inProgress,
    'DONE': AppTravelStatus.completed,
    'COMPLETED': AppTravelStatus.completed,
  }.entries) {
    test('공개 여행 상태 ${entry.key}를 파싱한다', () {
      expect(
        LikedTravelModel.fromJson(_travelJson(entry.key)).status,
        entry.value,
      );
    });
  }
}
