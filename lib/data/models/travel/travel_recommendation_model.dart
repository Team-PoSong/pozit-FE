import 'travel_course_model.dart';

class RecommendedPlaceModel {
  const RecommendedPlaceModel({
    required this.orderIndex,
    required this.contentId,
    required this.contentTypeId,
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.legalDongRegionCode,
    this.legalDongSigunguCode,
  });

  final int orderIndex;
  final String contentId;
  final String contentTypeId;
  final String title;
  final String address;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? legalDongRegionCode;
  final String? legalDongSigunguCode;

  factory RecommendedPlaceModel.fromJson(Map<String, dynamic> json) {
    return RecommendedPlaceModel(
      orderIndex: json['orderIndex'] as int? ?? 0,
      contentId:
          json['contentId'] as String? ?? json['contentid'] as String? ?? '',
      contentTypeId:
          json['contentTypeId'] as String? ??
          json['contenttypeid'] as String? ??
          '',
      title: json['title'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      legalDongRegionCode: json['legalDongRegionCode'] as String?,
      legalDongSigunguCode: json['legalDongSigunguCode'] as String?,
    );
  }

  Map<String, dynamic> toCommitJson() => {
    'orderIndex': orderIndex,
    'contentId': contentId,
    'contentTypeId': contentTypeId,
    'title': title,
    'address': address,
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    if (legalDongRegionCode != null) 'legalDongRegionCode': legalDongRegionCode,
    if (legalDongSigunguCode != null)
      'legalDongSigunguCode': legalDongSigunguCode,
  };
}

class RecommendedDayModel {
  const RecommendedDayModel({
    required this.dayNumber,
    required this.date,
    required this.places,
  });

  final int dayNumber;
  final DateTime date;
  final List<RecommendedPlaceModel> places;

  List<RecommendedPlaceModel> get validCommitPlaces => places
      .where(
        (place) =>
            place.contentId.trim().isNotEmpty && place.title.trim().isNotEmpty,
      )
      .toList();

  factory RecommendedDayModel.fromJson(Map<String, dynamic> json) {
    return RecommendedDayModel(
      dayNumber: json['dayNumber'] as int? ?? 0,
      date: DateTime.parse(json['date'] as String),
      places: (json['places'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                RecommendedPlaceModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toCommitJson() => {
    'dayNumber': dayNumber,
    'places': places.map((place) => place.toCommitJson()).toList(),
  };
}

class TravelRecommendationModel {
  const TravelRecommendationModel({
    required this.travelId,
    required this.dayCount,
    required this.days,
  });

  final int travelId;
  final int dayCount;
  final List<RecommendedDayModel> days;

  factory TravelRecommendationModel.fromJson(Map<String, dynamic> json) {
    return TravelRecommendationModel(
      travelId: json['travelId'] as int,
      dayCount: json['dayCount'] as int? ?? 0,
      days: (json['days'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                RecommendedDayModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toCommitJson() => {
    'days': [
      for (final day in days)
        if (day.validCommitPlaces.isNotEmpty)
          {
            'dayNumber': day.dayNumber,
            'places': day.validCommitPlaces
                .map((place) => place.toCommitJson())
                .toList(),
          },
    ],
  };

  List<TravelCourseModel> toPreviewCourses() {
    var syntheticSpotId = -1;
    final sortedDays = [...days]
      ..sort((left, right) => left.dayNumber.compareTo(right.dayNumber));
    return [
      for (var index = 0; index < sortedDays.length; index++)
        TravelCourseModel(
          courseId: -(index + 1),
          // 일부 추천 응답은 첫 일차를 0으로 내려줍니다. 앱의 일차 선택은
          // 1부터 시작하므로 응답 순서를 기준으로 연속된 번호로 정규화합니다.
          dayNumber: index + 1,
          date: sortedDays[index].date,
          spots: [
            for (final place in sortedDays[index].places)
              CourseSpotModel(
                courseSpotId: syntheticSpotId,
                touristSpotId: syntheticSpotId--,
                name: place.title,
                address: place.address,
                latitude: place.latitude,
                longitude: place.longitude,
                orderIndex: place.orderIndex,
                status: 'notVisited',
                imageUrl: place.imageUrl,
              ),
          ],
        ),
    ];
  }
}
