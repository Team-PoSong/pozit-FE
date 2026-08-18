import '../../core/design_system/app_travel_status.dart';
import '../../data/models/saved_travel_model.dart';
import '../../data/models/tourist_spot_model.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import 'travel_creation_data.dart';

abstract final class TravelCreationPipeline {
  static int maximumTripNights(TravelCreationMethod method) =>
      method == TravelCreationMethod.wish ? 4 : 3;

  static bool requiresPreferences(TravelCreationMethod method) =>
      method == TravelCreationMethod.recommendation;

  static int dayCount(TravelCreationDraft draft) =>
      draft.dateRange.duration.inDays.clamp(
        0,
        maximumTripNights(draft.creationMethod),
      ) +
      1;

  static Map<int, List<TouristSpotModel>> initialSpotsByDay(
    TravelCreationDraft draft,
  ) {
    final result = <int, List<TouristSpotModel>>{};
    final maximumDay = dayCount(draft);
    for (final course in draft.initialCourses) {
      if (course.dayNumber > maximumDay) continue;
      result[course.dayNumber] = [
        for (final spot in course.spots)
          TouristSpotModel(
            touristSpotId: spot.touristSpotId,
            name: spot.name,
            address: spot.address,
            latitude: spot.latitude,
            longitude: spot.longitude,
          ),
      ];
    }
    return result;
  }

  static List<TravelCourseModel> buildCourses(
    TravelCreationDraft draft,
    Map<int, List<TouristSpotModel>> spotsByDay,
  ) {
    return List.generate(dayCount(draft), (index) {
      final dayNumber = index + 1;
      final spots = spotsByDay[dayNumber] ?? const <TouristSpotModel>[];
      return TravelCourseModel(
        courseId: dayNumber,
        dayNumber: dayNumber,
        date: draft.dateRange.start.add(Duration(days: index)),
        spots: [
          for (var spotIndex = 0; spotIndex < spots.length; spotIndex++)
            CourseSpotModel(
              courseSpotId: spots[spotIndex].touristSpotId,
              touristSpotId: spots[spotIndex].touristSpotId,
              name: spots[spotIndex].name,
              address: spots[spotIndex].address,
              latitude: spots[spotIndex].latitude,
              longitude: spots[spotIndex].longitude,
              orderIndex: spotIndex,
              status: 'notVisited',
            ),
        ],
      );
    });
  }

  static SavedTravelModel buildSavedTravel(
    TravelCreationDraft draft,
    List<TravelCourseModel> courses, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final start = draft.dateRange.start;
    final startDate = DateTime(start.year, start.month, start.day);
    final daysUntilStart = startDate.difference(today).inDays;
    final tags = draft.tags.toList();

    return SavedTravelModel(
      id: 'created-${start.millisecondsSinceEpoch}',
      title: draft.name,
      location: draft.destination,
      dateText:
          '${start.month}/${start.day} ~ '
          '${draft.dateRange.end.month}/${draft.dateRange.end.day}',
      author: '나',
      info: TravelInfoCardModel(
        destination: draft.destination,
        startDate: start,
        endDate: draft.dateRange.end,
        companionCount: 1,
        tags: tags,
        visitedPlaceCount: 0,
        recordCount: 0,
        completionRate: 0,
      ),
      courses: courses,
      status: AppTravelStatus.upcoming,
      dDay: daysUntilStart < 0
          ? null
          : daysUntilStart == 0
          ? 'D-Day'
          : 'D-$daysUntilStart',
      tags: tags,
      participantCount: 1,
    );
  }
}
