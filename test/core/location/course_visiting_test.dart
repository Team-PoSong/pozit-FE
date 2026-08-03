import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;
import 'package:pozit/core/location/course_visiting.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';

CourseSpotModel _spot({
  int courseSpotId = 1,
  int touristSpotId = 1,
  double latitude = 35.8347,
  double longitude = 129.2247,
}) {
  return CourseSpotModel(
    courseSpotId: courseSpotId,
    touristSpotId: touristSpotId,
    name: '동궁과 월지',
    address: '경북 경주시 원화로 102',
    latitude: latitude,
    longitude: longitude,
    orderIndex: 0,
    status: 'notVisited',
  );
}

void main() {
  test('코스 반경 100m 이내면 방문 중으로 판단한다', () {
    final spot = _spot();
    // ~30m north of the spot.
    final nearby = LatLng(spot.latitude + 0.00027, spot.longitude);

    expect(isWithinCourseVisitingRadius(nearby, spot), isTrue);
  });

  test('코스 반경 100m를 벗어나면 방문 중이 아니다', () {
    final spot = _spot();
    // ~300m north of the spot.
    final far = LatLng(spot.latitude + 0.0027, spot.longitude);

    expect(isWithinCourseVisitingRadius(far, spot), isFalse);
  });

  test('현재 위치를 모르면 방문 중인 코스가 없다', () {
    final spots = [_spot()];

    expect(nearbyTouristSpotIds(null, spots), isEmpty);
  });

  test('반경 안에 있는 코스의 touristSpotId만 반환한다', () {
    final near = _spot(courseSpotId: 1, touristSpotId: 10);
    final far = _spot(
      courseSpotId: 2,
      touristSpotId: 20,
      latitude: near.latitude + 0.01,
    );
    final location = LatLng(near.latitude, near.longitude);

    expect(nearbyTouristSpotIds(location, [near, far]), {10});
  });

  test('현재 위치를 모르면 방문 중인 코스 포커스가 없다', () {
    final course = TravelCourseModel(
      courseId: 1,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: [_spot()],
    );

    expect(nearbyCourseFocus(null, [course]), isNull);
  });

  test('가까운 스팟이 없으면 방문 중인 코스 포커스가 없다', () {
    final spot = _spot();
    final course = TravelCourseModel(
      courseId: 1,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: [spot],
    );
    final far = LatLng(spot.latitude + 0.01, spot.longitude);

    expect(nearbyCourseFocus(far, [course]), isNull);
  });

  test('여러 날짜/코스 중 가까운 스팟이 속한 (dayNumber, courseIndex)를 반환한다', () {
    final farSpot = _spot(courseSpotId: 1, touristSpotId: 1, latitude: 35.0);
    final nearSpot = _spot(
      courseSpotId: 2,
      touristSpotId: 2,
      latitude: 35.8347,
      longitude: 129.2247,
    );

    final day1Course0 = TravelCourseModel(
      courseId: 1,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: [farSpot],
    );
    final day1Course1 = TravelCourseModel(
      courseId: 2,
      dayNumber: 1,
      date: DateTime(2026, 6, 5),
      spots: [farSpot],
    );
    final day2Course0 = TravelCourseModel(
      courseId: 3,
      dayNumber: 2,
      date: DateTime(2026, 6, 6),
      spots: [nearSpot],
    );

    final location = LatLng(nearSpot.latitude, nearSpot.longitude);

    final focus = nearbyCourseFocus(location, [
      day1Course0,
      day1Course1,
      day2Course0,
    ]);

    expect(focus, (dayNumber: 2, courseIndex: 0));
  });
}
