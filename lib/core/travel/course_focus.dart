import '../../data/models/travel/travel_course_model.dart';

bool isCourseCompleted(TravelCourseModel course) {
  return course.spots.isNotEmpty &&
      course.spots.every((spot) => spot.status == 'visited');
}

/// Index of the item right after the last item for which [isDone] is true;
/// 0 if no item is done, and clamped to the last index if the last item is
/// done (there's nothing after it to focus on).
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

/// The backend-driven default first-open focus: the day and within-day
/// course index of "what to do next" — the course right after the last
/// fully-completed one, or the very first course if none are completed yet.
///
/// [allCourses] is assumed to already be in itinerary order (the API doesn't
/// provide a separate ordering field among courses sharing a day, so array
/// order is treated as itinerary order, matching the rest of the app).
({int dayNumber, int courseIndex}) defaultTravelFocus(
  List<TravelCourseModel> allCourses,
) {
  final dayNumbers = allCourses.map((c) => c.dayNumber).toSet().toList()
    ..sort();
  if (dayNumbers.isEmpty) return (dayNumber: 1, courseIndex: 0);

  bool isDayCompleted(int dayNumber) => allCourses
      .where((c) => c.dayNumber == dayNumber)
      .every(isCourseCompleted);

  final focusedDayIndex = focusedIndexAfterLastCompleted(
    dayNumbers,
    isDayCompleted,
  );
  final focusedDay = dayNumbers[focusedDayIndex];

  final coursesForFocusedDay = allCourses
      .where((c) => c.dayNumber == focusedDay)
      .toList();
  final focusedCourseIndex = focusedIndexAfterLastCompleted(
    coursesForFocusedDay,
    isCourseCompleted,
  );

  return (dayNumber: focusedDay, courseIndex: focusedCourseIndex);
}
