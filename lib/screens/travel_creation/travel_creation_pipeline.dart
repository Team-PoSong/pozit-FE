import '../../data/models/tourist_spot_model.dart';
import '../../data/models/travel/travel_create_model.dart';
import '../../data/models/travel/like_based_travel_model.dart';
import 'travel_creation_data.dart';

abstract final class TravelCreationPipeline {
  static int maximumTripNights(TravelCreationMethod method) =>
      method == TravelCreationMethod.wish ? 4 : 3;

  static bool requiresPreferences(TravelCreationMethod method) =>
      method == TravelCreationMethod.recommendation;

  static TravelCreateRequest buildCreateRequest(TravelCreationDraft draft) {
    final regionCode = draft.regionCode;
    if (regionCode == null || regionCode.isEmpty) {
      throw StateError('여행 지역 코드가 필요합니다.');
    }
    if (draft.tagIds.isEmpty) {
      throw StateError('여행 태그 ID가 필요합니다.');
    }

    return TravelCreateRequest(
      title: draft.name,
      destination: draft.destination,
      regionCode: regionCode,
      startDate: draft.dateRange.start,
      endDate: draft.dateRange.end,
      tagIds: draft.tagIds,
      transportation: transportationCode(draft.transportation),
      travelStyle: travelStyleCode(draft.densityLevel),
    );
  }

  static LikeBasedTravelCreateRequest buildLikeBasedCreateRequest(
    TravelCreationDraft draft,
    Map<int, List<TouristSpotModel>> spotsByDay,
  ) {
    final sourceTravelId = draft.sourceTravelId;
    if (sourceTravelId == null) {
      throw StateError('원본 여행 ID가 필요합니다.');
    }
    if (draft.tagIds.isEmpty) {
      throw StateError('여행 태그 ID가 필요합니다.');
    }

    return LikeBasedTravelCreateRequest(
      sourceTravelId: sourceTravelId,
      title: draft.name,
      startDate: draft.dateRange.start,
      endDate: draft.dateRange.end,
      tagIds: draft.tagIds,
      transportation: transportationCode(draft.transportation),
      travelStyle: travelStyleCode(draft.densityLevel),
      backgroundImageUrl: draft.backgroundImageUrl,
      courses: [
        for (var day = 1; day <= dayCount(draft); day++)
          LikeBasedCourseRequest(
            dayNumber: day,
            touristSpotIds: (spotsByDay[day] ?? const [])
                .map((spot) => spot.touristSpotId)
                .toList(),
          ),
      ],
    );
  }

  static String? transportationCode(String? transportation) =>
      switch (transportation) {
        '자동차' => 'CAR',
        '도보' || '자전거' => 'WALK',
        '대중교통' => 'PUBLIC',
        _ => null,
      };

  static String? travelStyleCode(int? densityLevel) => switch (densityLevel) {
    0 => 'RELAXED',
    1 => 'NORMAL',
    2 => 'TIGHT',
    _ => null,
  };

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
      final daySpots = result.putIfAbsent(
        course.dayNumber,
        () => <TouristSpotModel>[],
      );
      daySpots.addAll([
        for (final spot in course.spots)
          TouristSpotModel(
            touristSpotId: spot.touristSpotId,
            name: spot.name,
            address: spot.address,
            latitude: spot.latitude,
            longitude: spot.longitude,
          ),
      ]);
    }
    return result;
  }
}
