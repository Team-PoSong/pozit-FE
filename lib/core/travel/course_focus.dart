import '../../data/models/travel/travel_course_model.dart';

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
/// spot index of "what to do next" — the spot right after the last visited
/// one in that day's merged spot list, or the very first spot if none are
/// visited yet. The map card pages through spots (not courses) since a day
/// can have a single course with several spots.
///
/// [allCourses] is assumed to already be in itinerary order (the API doesn't
/// provide a separate ordering field among courses sharing a day, so array
/// order is treated as itinerary order, matching the rest of the app).
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
