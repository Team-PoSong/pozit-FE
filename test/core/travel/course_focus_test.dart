import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/travel/course_focus.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';

CourseSpotModel _spot({required String status}) {
  return CourseSpotModel(
    courseSpotId: 1,
    touristSpotId: 1,
    name: '테스트 스팟',
    latitude: 0,
    longitude: 0,
    orderIndex: 0,
    status: status,
  );
}

TravelCourseModel _course({
  required int courseId,
  required int dayNumber,
  required bool completed,
}) {
  return TravelCourseModel(
    courseId: courseId,
    dayNumber: dayNumber,
    date: DateTime(2026, 6, 5),
    spots: [_spot(status: completed ? 'visited' : 'notVisited')],
  );
}

void main() {
  group('isCourseCompleted', () {
    test('모든 스팟이 방문 완료면 완료된 코스다', () {
      final course = _course(courseId: 1, dayNumber: 1, completed: true);
      expect(isCourseCompleted(course), isTrue);
    });

    test('스팟이 하나라도 미방문이면 완료된 코스가 아니다', () {
      final course = TravelCourseModel(
        courseId: 1,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
        spots: [_spot(status: 'visited'), _spot(status: 'notVisited')],
      );
      expect(isCourseCompleted(course), isFalse);
    });

    test('스팟이 없으면 완료된 코스가 아니다', () {
      final course = TravelCourseModel(
        courseId: 1,
        dayNumber: 1,
        date: DateTime(2026, 6, 5),
      );
      expect(isCourseCompleted(course), isFalse);
    });
  });

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
    test('코스가 없으면 1일차 0번 코스를 기본값으로 반환한다', () {
      final focus = defaultTravelFocus(const []);
      expect(focus, (dayNumber: 1, courseIndex: 0));
    });

    test('완료, 완료, 미방문(포커스) — 같은 날 코스 3개', () {
      final courses = [
        _course(courseId: 1, dayNumber: 1, completed: true),
        _course(courseId: 2, dayNumber: 1, completed: true),
        _course(courseId: 3, dayNumber: 1, completed: false),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, courseIndex: 2));
    });

    test('완료, 미방문, 완료, 미방문(포커스) — 같은 날 코스 4개', () {
      final courses = [
        _course(courseId: 1, dayNumber: 1, completed: true),
        _course(courseId: 2, dayNumber: 1, completed: false),
        _course(courseId: 3, dayNumber: 1, completed: true),
        _course(courseId: 4, dayNumber: 1, completed: false),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, courseIndex: 3));
    });

    test('미방문(포커스), 미방문, 미방문 — 완료된 코스가 없는 하루', () {
      final courses = [
        _course(courseId: 1, dayNumber: 1, completed: false),
        _course(courseId: 2, dayNumber: 1, completed: false),
        _course(courseId: 3, dayNumber: 1, completed: false),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 1, courseIndex: 0));
    });

    test('1일차가 모두 완료되면 2일차의 첫 코스로 넘어간다', () {
      final courses = [
        _course(courseId: 1, dayNumber: 1, completed: true),
        _course(courseId: 2, dayNumber: 2, completed: false),
        _course(courseId: 3, dayNumber: 2, completed: false),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 2, courseIndex: 0));
    });

    test('모든 날짜가 완료되면 마지막 날 마지막 코스로 고정된다', () {
      final courses = [
        _course(courseId: 1, dayNumber: 1, completed: true),
        _course(courseId: 2, dayNumber: 2, completed: true),
      ];
      expect(defaultTravelFocus(courses), (dayNumber: 2, courseIndex: 0));
    });
  });
}
