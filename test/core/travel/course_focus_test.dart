import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/travel/course_focus.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';

CourseSpotModel _spot({
  required int touristSpotId,
  required int orderIndex,
  required bool visited,
}) {
  return CourseSpotModel(
    courseSpotId: touristSpotId,
    touristSpotId: touristSpotId,
    name: '스팟$touristSpotId',
    latitude: 0,
    longitude: 0,
    orderIndex: orderIndex,
    status: visited ? 'visited' : 'notVisited',
  );
}

TravelCourseModel _courseWithSpots(
  int courseId,
  int dayNumber,
  List<bool> visitedFlags,
) {
  return TravelCourseModel(
    courseId: courseId,
    dayNumber: dayNumber,
    date: DateTime(2026, 6, 5),
    spots: [
      for (var i = 0; i < visitedFlags.length; i++)
        _spot(
          touristSpotId: courseId * 100 + i,
          orderIndex: i,
          visited: visitedFlags[i],
        ),
    ],
  );
}

void main() {
  group('focusedIndexAfterLastCompleted', () {
    test('완료, 완료, 미방문(포커스) 패턴', () {
      final done = [true, true, false];
      final index = focusedIndexAfterLastCompleted(done, (d) => d);
      expect(index, 2);
    });

    test('완료, 미방문, 완료, 미방문(포커스) 패턴 — 첫 미방문이 아니라 마지막 완료 다음이다', () {
      final done = [true, false, true, false];
      final index = focusedIndexAfterLastCompleted(done, (d) => d);
      expect(index, 3);
    });

    test('미방문(포커스), 미방문, 미방문 패턴 — 완료가 없으면 첫 항목이다', () {
      final done = [false, false, false];
      final index = focusedIndexAfterLastCompleted(done, (d) => d);
      expect(index, 0);
    });

    test('빈 목록이면 0을 반환한다', () {
      expect(focusedIndexAfterLastCompleted<bool>([], (d) => d), 0);
    });

    test('모두 완료면 마지막 인덱스로 고정된다', () {
      final done = [true, true, true];
      final index = focusedIndexAfterLastCompleted(done, (d) => d);
      expect(index, 2);
    });
  });

  group('defaultTravelFocus', () {
    test('코스가 없으면 1일차 0번 장소를 기본값으로 반환한다', () {
      final focus = defaultTravelFocus(const []);
      expect(focus, (dayNumber: 1, spotIndex: 0));
    });

    test('완료, 완료, 미방문(포커스) — 하루 코스 1개, 장소 3개', () {
      final courses = [
        _courseWithSpots(1, 1, [true, true, false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, spotIndex: 2));
    });

    test('완료, 미방문, 완료, 미방문(포커스) — 하루 코스 1개, 장소 4개', () {
      final courses = [
        _courseWithSpots(1, 1, [true, false, true, false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, spotIndex: 3));
    });

    test('미방문(포커스), 미방문, 미방문 — 완료된 장소가 없는 하루', () {
      final courses = [
        _courseWithSpots(1, 1, [false, false, false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, spotIndex: 0));
    });

    test('같은 날 코스가 여러 개면 장소를 순서대로 합쳐서 계산한다', () {
      final courses = [
        _courseWithSpots(1, 1, [true]),
        _courseWithSpots(2, 1, [false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, spotIndex: 1));
    });

    test('1일차가 모두 완료되면 2일차의 첫 장소로 넘어간다', () {
      final courses = [
        _courseWithSpots(1, 1, [true, true]),
        _courseWithSpots(2, 2, [false, false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 2, spotIndex: 0));
    });

    test('모든 날짜가 완료되면 마지막 날 마지막 장소로 고정된다', () {
      final courses = [
        _courseWithSpots(1, 1, [true]),
        _courseWithSpots(2, 2, [true, true]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 2, spotIndex: 1));
    });

    test('첫 날짜에 장소가 없으면 장소가 있는 다음 날짜로 포커스한다', () {
      final courses = [
        _courseWithSpots(1, 1, []),
        _courseWithSpots(2, 2, [false, false]),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 2, spotIndex: 0));
    });

    test('모든 날짜에 장소가 없으면 첫 날짜 0번으로 고정된다', () {
      final courses = [
        _courseWithSpots(1, 1, []),
        _courseWithSpots(2, 2, []),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, spotIndex: 0));
    });
  });
}
