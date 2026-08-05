import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';

Map<String, dynamic> _spotJson({String? status, String? address}) {
  return {
    'courseSpotId': 1,
    'touristSpotId': 1,
    'name': '동궁과 월지',
    if (address != null) 'address': address,
    'latitude': 35.8347,
    'longitude': 129.2247,
    'orderIndex': 0,
    'status': status ?? 'VISITED',
  };
}

void main() {
  group('CourseSpotModel.fromJson', () {
    test('address가 없으면 빈 문자열로 채운다', () {
      final spot = CourseSpotModel.fromJson(_spotJson());
      expect(spot.address, '');
    });

    test('address가 있으면 그대로 사용한다', () {
      final spot = CourseSpotModel.fromJson(
        _spotJson(address: '경북 경주시 원화로 102'),
      );
      expect(spot.address, '경북 경주시 원화로 102');
    });

    for (final status in ['VISITED', 'visited', 'DONE', 'completed']) {
      test('status "$status"는 visited로 정규화된다', () {
        final spot = CourseSpotModel.fromJson(_spotJson(status: status));
        expect(spot.status, 'visited');
      });
    }

    for (final status in ['NOT_VISITED', 'notVisited', 'PENDING', 'UNKNOWN_VALUE']) {
      test('status "$status"는 notVisited로 정규화된다', () {
        final spot = CourseSpotModel.fromJson(_spotJson(status: status));
        expect(spot.status, 'notVisited');
      });
    }

    test('pozings가 없으면 빈 목록이다', () {
      final spot = CourseSpotModel.fromJson(_spotJson());
      expect(spot.pozings, isEmpty);
    });

    test('imageUrl이 없으면 빈 문자열로 채운다 (getTravelDetail 응답 대응)', () {
      final spot = CourseSpotModel.fromJson(_spotJson());
      expect(spot.imageUrl, '');
    });

    test('imageUrl이 있으면 그대로 사용한다 (getCourseDetail 응답 대응)', () {
      final json = _spotJson()..['imageUrl'] = 'https://example.com/spot.jpg';
      final spot = CourseSpotModel.fromJson(json);
      expect(spot.imageUrl, 'https://example.com/spot.jpg');
    });
  });

  group('TravelCourseModel.fromJson', () {
    test('spots를 CourseSpotModel 목록으로 파싱한다', () {
      final course = TravelCourseModel.fromJson({
        'courseId': 1,
        'dayNumber': 1,
        'date': '2026-06-05',
        'spots': [_spotJson()],
      });

      expect(course.spots, hasLength(1));
      expect(course.spots.first.status, 'visited');
    });

    test('initialFocusSpotId가 없으면 null이다 (getTravelDetail 응답 대응)', () {
      final course = TravelCourseModel.fromJson({
        'courseId': 1,
        'dayNumber': 1,
        'date': '2026-06-05',
        'spots': [_spotJson()],
      });

      expect(course.initialFocusSpotId, isNull);
    });

    test('initialFocusSpotId가 있으면 그대로 사용한다 (getCourseDetail 응답 대응)', () {
      final course = TravelCourseModel.fromJson({
        'courseId': 1,
        'dayNumber': 1,
        'date': '2026-06-05',
        'spots': [_spotJson()],
        'initialFocusSpotId': 1,
      });

      expect(course.initialFocusSpotId, 1);
    });
  });
}
