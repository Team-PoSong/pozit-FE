import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/tourist_spot_search_result_model.dart';

void main() {
  group('TouristSpotSearchResultModel.fromJson', () {
    test('관광공사 API의 소문자 키(contentid/contenttypeid)를 파싱한다', () {
      final spot = TouristSpotSearchResultModel.fromJson({
        'contentid': '126508',
        'contenttypeid': '12',
        'title': '경복궁',
        'address': '서울특별시 종로구 사직로 161',
        'imageUrl': 'https://example.com/spot.jpg',
        'longitude': 126.976889,
        'latitude': 37.579617,
      });

      expect(spot.contentId, '126508');
      expect(spot.contentTypeId, '12');
      expect(spot.title, '경복궁');
      expect(spot.address, '서울특별시 종로구 사직로 161');
      expect(spot.imageUrl, 'https://example.com/spot.jpg');
      expect(spot.longitude, closeTo(126.976889, 1e-9));
      expect(spot.latitude, closeTo(37.579617, 1e-9));
    });

    test('imageUrl이 없으면 빈 문자열로 채운다', () {
      final spot = TouristSpotSearchResultModel.fromJson({
        'contentid': '126508',
        'contenttypeid': '12',
        'title': '경복궁',
        'address': '서울특별시 종로구 사직로 161',
        'longitude': 126.976889,
        'latitude': 37.579617,
      });

      expect(spot.imageUrl, '');
    });
  });

  group('TouristSpotSearchPage.fromJson', () {
    test('places 목록과 페이지 정보를 파싱한다', () {
      final page = TouristSpotSearchPage.fromJson({
        'currentCursor': 1,
        'nextCursor': 2,
        'hasNext': true,
        'places': [
          {
            'contentid': '126508',
            'contenttypeid': '12',
            'title': '경복궁',
            'address': '서울특별시 종로구 사직로 161',
            'longitude': 126.976889,
            'latitude': 37.579617,
          },
        ],
      });

      expect(page.currentCursor, 1);
      expect(page.nextCursor, 2);
      expect(page.hasNext, isTrue);
      expect(page.places, hasLength(1));
      expect(page.places.first.title, '경복궁');
    });

    test('마지막 페이지에서는 nextCursor가 없을 수 있다', () {
      final page = TouristSpotSearchPage.fromJson({
        'currentCursor': 3,
        'hasNext': false,
        'places': const [],
      });

      expect(page.nextCursor, isNull);
      expect(page.hasNext, isFalse);
      expect(page.places, isEmpty);
    });
  });
}
