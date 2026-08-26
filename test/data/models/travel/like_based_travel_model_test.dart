import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/travel/like_based_travel_model.dart';

void main() {
  test('찜 기반 여행 초안 응답을 파싱한다', () {
    final draft = LikeBasedTravelDraftModel.fromJson({
      'sourceTravelId': 1,
      'title': '서울 감성 여행',
      'destination': '서울특별시',
      'regionCode': '11000',
      'tagIds': [1, 2],
      'transportation': 'PUBLIC',
      'travelStyle': 'RELAXED',
      'backgroundImageUrl': 'https://example.com/background.jpg',
    });

    expect(draft.sourceTravelId, 1);
    expect(draft.regionCode, '11000');
    expect(draft.tagIds, [1, 2]);
  });

  test('찜 기반 여행 최종 생성 요청을 API 형식으로 변환한다', () {
    final request = LikeBasedTravelCreateRequest(
      sourceTravelId: 1,
      title: '내가 가는 서울 여행',
      startDate: DateTime(2026, 8, 10),
      endDate: DateTime(2026, 8, 12),
      transportation: 'PUBLIC',
      travelStyle: 'RELAXED',
      tagIds: const [1, 2],
      courses: const [
        LikeBasedCourseRequest(dayNumber: 1, touristSpotIds: [10, 11, 12]),
      ],
    );

    expect(request.toJson(), {
      'sourceTravelId': 1,
      'title': '내가 가는 서울 여행',
      'startDate': '2026-08-10',
      'endDate': '2026-08-12',
      'transportation': 'PUBLIC',
      'travelStyle': 'RELAXED',
      'tagIds': [1, 2],
      'courses': [
        {
          'dayNumber': 1,
          'touristSpotIds': [10, 11, 12],
        },
      ],
    });
  });
}
