import '../models/travel/travel_course_model.dart';

class MockCourseSpot {
  const MockCourseSpot({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
}

List<TravelCourseModel> buildMockTravelCourses({
  required DateTime startDate,
  required int dayCount,
  required List<MockCourseSpot> spots,
  int spotsPerDay = 1,
  bool repeatSpotsEachDay = false,
  bool firstSpotVisited = false,
}) {
  return List.generate(dayCount, (dayIndex) {
    final dayNumber = dayIndex + 1;
    final daySpots = repeatSpotsEachDay
        ? spots
        : spots.skip(dayIndex * spotsPerDay).take(spotsPerDay).toList();
    return TravelCourseModel(
      courseId: dayNumber,
      dayNumber: dayNumber,
      date: startDate.add(Duration(days: dayIndex)),
      spots: [
        for (var spotIndex = 0; spotIndex < daySpots.length; spotIndex++)
          CourseSpotModel(
            courseSpotId: dayNumber * 100 + spotIndex,
            touristSpotId: dayNumber * 100 + spotIndex,
            name: daySpots[spotIndex].name,
            address: daySpots[spotIndex].address,
            latitude: daySpots[spotIndex].latitude,
            longitude: daySpots[spotIndex].longitude,
            orderIndex: spotIndex,
            status: firstSpotVisited && spotIndex == 0
                ? 'visited'
                : 'notVisited',
          ),
      ],
    );
  });
}
