import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/travel/travel_recommendation_model.dart';

void main() {
  test('추천 미리보기 응답을 화면 코스와 commit 요청으로 변환한다', () {
    final recommendation = TravelRecommendationModel.fromJson({
      'travelId': 31,
      'dayCount': 1,
      'days': [
        {
          'dayNumber': 1,
          'date': '2026-08-22',
          'places': [
            {
              'orderIndex': 0,
              'contentId': '126508',
              'contentTypeId': '12',
              'title': '경복궁',
              'address': '서울특별시 종로구 사직로 161',
              'imageUrl': 'https://example.com/image.jpg',
              'latitude': 37.579617,
              'longitude': 126.976889,
            },
          ],
        },
      ],
    });

    expect(recommendation.travelId, 31);
    expect(recommendation.toPreviewCourses().single.spots.single.name, '경복궁');
    expect(recommendation.toCommitJson(), {
      'days': [
        {
          'dayNumber': 1,
          'places': [
            {
              'orderIndex': 0,
              'contentId': '126508',
              'contentTypeId': '12',
              'title': '경복궁',
              'address': '서울특별시 종로구 사직로 161',
              'imageUrl': 'https://example.com/image.jpg',
              'latitude': 37.579617,
              'longitude': 126.976889,
            },
          ],
        },
      ],
    });
  });

  test('관광공사 소문자 contentid 응답도 commit 요청에 유지한다', () {
    final recommendation = TravelRecommendationModel.fromJson({
      'travelId': 31,
      'dayCount': 1,
      'days': [
        {
          'dayNumber': 1,
          'date': '2026-08-22',
          'places': [
            {
              'orderIndex': 0,
              'contentid': '126508',
              'contenttypeid': '12',
              'title': '경복궁',
              'latitude': 37.579617,
              'longitude': 126.976889,
            },
          ],
        },
      ],
    });

    final days = recommendation.toCommitJson()['days'] as List<dynamic>;
    final places = (days.single as Map<String, dynamic>)['places'] as List;
    expect((places.single as Map<String, dynamic>)['contentId'], '126508');
  });
}
