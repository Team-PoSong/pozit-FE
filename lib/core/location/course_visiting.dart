import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../data/models/travel/active_course_spot_model.dart';
import '../../data/models/travel/travel_course_model.dart';

const double kCourseVisitingRadiusMeters = 100000.0;

bool _isWithinRadius(LatLng location, double latitude, double longitude) {
  final distanceMeters = Geolocator.distanceBetween(
    location.latitude,
    location.longitude,
    latitude,
    longitude,
  );
  return distanceMeters <= kCourseVisitingRadiusMeters;
}

bool isWithinCourseVisitingRadius(LatLng location, CourseSpotModel spot) {
  return _isWithinRadius(location, spot.latitude, spot.longitude);
}

ActiveCourseSpotModel? nearbyActiveCourseSpot(
  LatLng? location,
  List<ActiveCourseSpotModel> spots,
) {
  if (location == null) return null;
  for (final spot in spots) {
    if (_isWithinRadius(location, spot.latitude, spot.longitude)) return spot;
  }
  return null;
}

Set<int> nearbyTouristSpotIds(
  LatLng? location,
  Iterable<CourseSpotModel> spots,
) {
  if (location == null) return const {};
  return {
    for (final spot in spots)
      if (isWithinCourseVisitingRadius(location, spot)) spot.touristSpotId,
  };
}

({int dayNumber, int spotIndex})? nearbyCourseFocus(
  LatLng? location,
  List<TravelCourseModel> allCourses,
) {
  if (location == null) return null;

  final dayNumbers = allCourses.map((c) => c.dayNumber).toSet().toList()
    ..sort();
  for (final dayNumber in dayNumbers) {
    final spotsForDay = mergeSpotsForDay(allCourses, dayNumber);
    for (var i = 0; i < spotsForDay.length; i++) {
      if (isWithinCourseVisitingRadius(location, spotsForDay[i])) {
        return (dayNumber: dayNumber, spotIndex: i);
      }
    }
  }
  return null;
}
