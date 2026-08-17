import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/tourist_spot_rank_model.dart';

void main() {
  group('TouristSpotRankModel.fromJson', () {
    test('필드를 그대로 파싱한다', () {
      final rank = TouristSpotRankModel.fromJson({
        'rank': 1,
        'touristSpotId': 1,
        'title': '경복궁',
        'address': '서울특별시 종로구 사직로 161',
        'latitude': 37.5796,
        'longitude': 126.9770,
        'imageUrl': 'https://example.com/spot.jpg',
        'courseSpotCount': 12,
      });

      expect(rank.rank, 1);
      expect(rank.touristSpotId, 1);
      expect(rank.title, '경복궁');
      expect(rank.address, '서울특별시 종로구 사직로 161');
      expect(rank.latitude, 37.5796);
      expect(rank.longitude, 126.9770);
      expect(rank.imageUrl, 'https://example.com/spot.jpg');
      expect(rank.courseSpotCount, 12);
    });

    test('imageUrl이 없으면 빈 문자열로 채운다', () {
      final rank = TouristSpotRankModel.fromJson({
        'rank': 1,
        'touristSpotId': 1,
        'title': '경복궁',
        'address': '서울특별시 종로구 사직로 161',
        'courseSpotCount': 12,
      });

      expect(rank.imageUrl, '');
    });

    test('latitude/longitude가 없으면 0으로 채운다', () {
      final rank = TouristSpotRankModel.fromJson({
        'rank': 1,
        'touristSpotId': 1,
        'title': '경복궁',
        'address': '서울특별시 종로구 사직로 161',
        'courseSpotCount': 12,
      });

      expect(rank.latitude, 0);
      expect(rank.longitude, 0);
    });
  });

  group('TouristSpotRankPage.fromJson', () {
    test('ranks 목록과 페이지 정보를 파싱한다', () {
      final page = TouristSpotRankPage.fromJson({
        'currentCursor': 1,
        'nextCursor': 2,
        'hasNext': true,
        'size': 1,
        'ranks': [
          {
            'rank': 1,
            'touristSpotId': 1,
            'title': '경복궁',
            'address': '서울특별시 종로구 사직로 161',
            'imageUrl': 'https://example.com/spot.jpg',
            'courseSpotCount': 12,
          },
        ],
      });

      expect(page.currentCursor, 1);
      expect(page.nextCursor, 2);
      expect(page.hasNext, isTrue);
      expect(page.ranks, hasLength(1));
      expect(page.ranks.first.title, '경복궁');
    });

    test('마지막 페이지에서는 nextCursor가 없을 수 있다', () {
      final page = TouristSpotRankPage.fromJson({
        'currentCursor': 3,
        'hasNext': false,
        'ranks': const [],
      });

      expect(page.nextCursor, isNull);
      expect(page.hasNext, isFalse);
      expect(page.ranks, isEmpty);
    });
  });
}
