import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel/public_travel_detail_model.dart';

void main() {
  test('공개 여행 상세의 COMPLETED 상태를 파싱한다', () {
    final detail = PublicTravelDetailModel.fromJson({
      'travelId': 1,
      'title': '완료 여행',
      'destination': '서울',
      'startDate': '2026-08-20',
      'endDate': '2026-08-21',
      'status': 'COMPLETED',
      'isPublic': true,
      'backgroundImageUrl': '',
      'leaderNickname': '포송',
      'memberCount': 1,
      'completionRate': 100,
      'totalSpotCount': 0,
      'totalPozingCount': 0,
      'tags': <String>[],
      'likeCount': 0,
      'isLiked': false,
      'courses': <dynamic>[],
      'members': <dynamic>[],
    });

    expect(detail.status, AppTravelStatus.completed);
  });
}
