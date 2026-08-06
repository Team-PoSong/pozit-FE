import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../data/models/travel/travel_course_model.dart';

/// A course spot is considered "visiting" once the user's current location
/// is within this many meters of it.
const double kCourseVisitingRadiusMeters = 100.0;

bool isWithinCourseVisitingRadius(LatLng location, CourseSpotModel spot) {
  final distanceMeters = Geolocator.distanceBetween(
    location.latitude,
    location.longitude,
    spot.latitude,
    spot.longitude,
  );
  return distanceMeters <= kCourseVisitingRadiusMeters;
}

/// The [CourseSpotModel.touristSpotId]s of every spot in [spots] that
/// [location] currently falls within [kCourseVisitingRadiusMeters] of.
///
/// Returns an empty set when [location] is unknown, so callers don't need a
/// separate null check before rendering "not visiting" state.
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

/// The day and within-day spot index (into that day's merged spot list, the
/// same list the map card pages through) of the first spot in [allCourses]'
/// day-ascending order that [location] currently falls within
/// [kCourseVisitingRadiusMeters] of.
///
/// Returns null when [location] is unknown or nothing is nearby, so callers
/// can fall back to a backend-driven default focus.
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
