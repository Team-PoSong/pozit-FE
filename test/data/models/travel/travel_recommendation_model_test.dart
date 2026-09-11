import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/travel/travel_recommendation_model.dart';

void main() {
  test('추천 카드와 같은 지역 공개 여행 두 개를 파싱한다', () {
    final card = TravelRecommendationCardModel.fromJson({
      'previewId': 'preview-1',
      'travelId': 31,
      'badge': 'Pozit Pick!',
      'cardTitle': '8월 추천, 양평은 어때요?',
      'travelTitle': '양평 여행',
      'destination': '경기도 양평군',
      'startDate': '2026-08-25',
      'endDate': '2026-08-27',
      'periodText': '8/25 ~ 8/27 · 2박 3일',
      'thumbnailImageUrl': 'https://example.com/recommendation.jpg',
      'tags': ['미식', '체험'],
      'memberCount': 1,
      'placeCount': 6,
      'relatedPublicTravels': [
        for (var id = 1; id <= 2; id++)
          {
            'travelId': id,
            'title': '공개 여행 $id',
            'destination': '경기도 양평군',
            'startDate': '2026-08-01',
            'endDate': '2026-08-02',
            'status': 'DONE',
            'isPublic': true,
            'backgroundImageUrl': '',
            'completionRate': 100,
            'tags': ['힐링'],
            'leaderNickname': '사용자$id',
            'memberCount': 2,
            'likeCount': 10 - id,
            'isLiked': false,
          },
      ],
    });

    expect(card.previewId, 'preview-1');
    expect(card.relatedPublicTravels, hasLength(2));
    expect(card.relatedPublicTravels.first.travelId, 1);
  });

  test('여행을 생성하지 않은 추천 미리보기의 null travelId를 파싱한다', () {
    final card = TravelRecommendationCardModel.fromJson({
      'previewId': 'preview-1',
      'travelId': null,
      'destination': '경상북도 경주시',
      'startDate': '2026-09-10',
      'endDate': '2026-09-12',
    });

    final recommendation = TravelRecommendationModel.fromJson({
      'travelId': null,
      'dayCount': 0,
      'days': <dynamic>[],
    });

    expect(card.travelId, isNull);
    expect(recommendation.travelId, isNull);
  });

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

  test('저장할 수 없는 장소는 미리보기와 commit 요청에서 모두 제외한다', () {
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
              'contentId': '',
              'title': '저장 불가 장소',
              'latitude': 0,
              'longitude': 0,
            },
            {
              'orderIndex': 1,
              'contentId': '126508',
              'title': '경복궁',
              'latitude': 37.579617,
              'longitude': 126.976889,
            },
          ],
        },
      ],
    });

    expect(
      recommendation.toPreviewCourses().single.spots.map((spot) => spot.name),
      ['경복궁'],
    );
    final days = recommendation.toCommitJson()['days'] as List<dynamic>;
    final places = (days.single as Map<String, dynamic>)['places'] as List;
    expect(places, hasLength(1));
    expect((places.single as Map<String, dynamic>)['title'], '경복궁');
  });

  test('빈 일차를 제외한 미리보기와 commit 일차 번호를 동일하게 재정렬한다', () {
    final recommendation = TravelRecommendationModel.fromJson({
      'travelId': 31,
      'dayCount': 2,
      'days': [
        {'dayNumber': 1, 'date': '2026-08-22', 'places': <dynamic>[]},
        {
          'dayNumber': 2,
          'date': '2026-08-23',
          'places': [
            {
              'contentId': '126508',
              'title': '경복궁',
              'latitude': 37.57,
              'longitude': 126.97,
            },
          ],
        },
      ],
    });

    expect(recommendation.toPreviewCourses().single.dayNumber, 1);
    final days = recommendation.toCommitJson()['days'] as List<dynamic>;
    expect((days.single as Map<String, dynamic>)['dayNumber'], 1);
  });
}
