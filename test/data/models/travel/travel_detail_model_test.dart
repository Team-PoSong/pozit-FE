import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel/travel_detail_model.dart';

Map<String, dynamic> _detailJson({String status = 'IN_PROGRESS'}) {
  return {
    'travelId': 1,
    'title': '경주 여행',
    'destination': '경주',
    'startDate': '2026-06-05',
    'endDate': '2026-06-07',
    'status': status,
    'isPublic': false,
    'backgroundImageUrl': 'https://example.com/bg.png',
    'inviteCode': 'AB12C',
    'completionRate': 60,
    'totalSpotCount': 12,
    'totalPozingCount': 48,
    'tags': ['기록', '미식'],
    'members': [
      {'userId': 1, 'nickname': '김윤지', 'role': 'LEADER'},
      {'userId': 2, 'nickname': '박서현', 'role': 'MEMBER'},
    ],
    'courses': [
      {
        'courseId': 1,
        'dayNumber': 1,
        'date': '2026-06-05',
        'spots': [
          {
            'courseSpotId': 1,
            'touristSpotId': 1,
            'name': '동궁과 월지',
            'latitude': 35.8347,
            'longitude': 129.2247,
            'orderIndex': 0,
            'status': 'VISITED',
            'pozings': [],
          },
        ],
      },
    ],
  };
}

void main() {
  group('TravelDetailModel.fromJson', () {
    test('전체 응답을 파싱한다', () {
      final detail = TravelDetailModel.fromJson(_detailJson());

      expect(detail.travelId, 1);
      expect(detail.destination, '경주');
      expect(detail.startDate, DateTime(2026, 6, 5));
      expect(detail.endDate, DateTime(2026, 6, 7));
      expect(detail.status, AppTravelStatus.inProgress);
      expect(detail.completionRate, 60);
      expect(detail.totalSpotCount, 12);
      expect(detail.totalPozingCount, 48);
      expect(detail.members, hasLength(2));
      expect(detail.members.first.isLeader, isTrue);
      expect(detail.courses, hasLength(1));
      expect(detail.courses.first.spots.first.status, 'visited');
    });

    for (final entry in {
      'UPCOMING': AppTravelStatus.upcoming,
      'IN_PROGRESS': AppTravelStatus.inProgress,
      'ongoing': AppTravelStatus.inProgress,
      'COMPLETED': AppTravelStatus.completed,
      'done': AppTravelStatus.completed,
      'SOME_UNKNOWN_VALUE': AppTravelStatus.upcoming,
    }.entries) {
      test('status "${entry.key}"는 ${entry.value}로 정규화된다', () {
        final detail = TravelDetailModel.fromJson(
          _detailJson(status: entry.key),
        );
        expect(detail.status, entry.value);
      });
    }
  });
}
