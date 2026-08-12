import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../data/models/travel_course_model.dart';

// TODO: API/위치 연동 검증 후 실제 서비스 반경으로 되돌립니다.
const double kCourseVisitingRadiusMeters = 1000000.0;

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
