import '../../data/models/travel/travel_course_model.dart';

int focusedIndexAfterLastCompleted<T>(
  List<T> items,
  bool Function(T item) isDone,
) {
  if (items.isEmpty) return 0;

  var lastDoneIndex = -1;
  for (var i = 0; i < items.length; i++) {
    if (isDone(items[i])) lastDoneIndex = i;
  }
  return (lastDoneIndex + 1).clamp(0, items.length - 1);
}

({int dayNumber, int spotIndex}) defaultTravelFocus(
  List<TravelCourseModel> allCourses,
) {
  final dayNumbers = allCourses.map((c) => c.dayNumber).toSet().toList()
    ..sort();
  if (dayNumbers.isEmpty) return (dayNumber: 1, spotIndex: 0);

  bool isSpotVisited(CourseSpotModel spot) => spot.status == 'visited';

  bool isDayCompleted(int dayNumber) {
    final spots = mergeSpotsForDay(allCourses, dayNumber);
    return spots.isNotEmpty && spots.every(isSpotVisited);
  }

  final focusedDayIndex = focusedIndexAfterLastCompleted(
    dayNumbers,
    isDayCompleted,
  );
  final focusedDay = dayNumbers[focusedDayIndex];

  final spotsForFocusedDay = mergeSpotsForDay(allCourses, focusedDay);
  final focusedSpotIndex = focusedIndexAfterLastCompleted(
    spotsForFocusedDay,
    isSpotVisited,
  );

  return (dayNumber: focusedDay, spotIndex: focusedSpotIndex);
}
