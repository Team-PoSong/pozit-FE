import '../like/liked_travel_model.dart';
import 'travel_course_model.dart';

class TravelRecommendationCardModel {
  const TravelRecommendationCardModel({
    required this.previewId,
    this.travelId,
    required this.badge,
    required this.cardTitle,
    required this.travelTitle,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.periodText,
    required this.thumbnailImageUrl,
    required this.tags,
    required this.memberCount,
    required this.placeCount,
    required this.relatedPublicTravels,
  });

  final String previewId;
  final int? travelId;
  final String badge;
  final String cardTitle;
  final String travelTitle;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String periodText;
  final String thumbnailImageUrl;
  final List<String> tags;
  final int memberCount;
  final int placeCount;
  final List<LikedTravelModel> relatedPublicTravels;

  factory TravelRecommendationCardModel.fromJson(Map<String, dynamic> json) {
    return TravelRecommendationCardModel(
      previewId: json['previewId'] as String,
      travelId: json['travelId'] as int?,
      badge: json['badge'] as String? ?? 'Pozit Pick!',
      cardTitle: json['cardTitle'] as String? ?? '',
      travelTitle: json['travelTitle'] as String? ?? '',
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      periodText: json['periodText'] as String? ?? '',
      thumbnailImageUrl: json['thumbnailImageUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      memberCount: json['memberCount'] as int? ?? 1,
      placeCount: json['placeCount'] as int? ?? 0,
      relatedPublicTravels:
          (json['relatedPublicTravels'] as List<dynamic>? ?? const [])
              .map(
                (item) =>
                    LikedTravelModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

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
    this.travelId,
    required this.dayCount,
    required this.days,
  });

  final int? travelId;
  final int dayCount;
  final List<RecommendedDayModel> days;

  factory TravelRecommendationModel.fromJson(Map<String, dynamic> json) {
    return TravelRecommendationModel(
      travelId: json['travelId'] as int?,
      dayCount: json['dayCount'] as int? ?? 0,
      days: (json['days'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                RecommendedDayModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  List<RecommendedDayModel> get _validSortedDays =>
      days.where((day) => day.validCommitPlaces.isNotEmpty).toList()
        ..sort((left, right) => left.dayNumber.compareTo(right.dayNumber));

  Map<String, dynamic> toCommitJson() => {
    'days': [
      for (var index = 0; index < _validSortedDays.length; index++)
        {
          'dayNumber': index + 1,
          'places': _validSortedDays[index].validCommitPlaces
              .map((place) => place.toCommitJson())
              .toList(),
        },
    ],
  };

  List<TravelCourseModel> toPreviewCourses() {
    var syntheticSpotId = -1;
    final sortedDays = _validSortedDays;
    return [
      for (var index = 0; index < sortedDays.length; index++)
        TravelCourseModel(
          courseId: -(index + 1),
          // 일부 추천 응답은 첫 일차를 0으로 내려줍니다. 앱의 일차 선택은
          // 1부터 시작하므로 응답 순서를 기준으로 연속된 번호로 정규화합니다.
          dayNumber: index + 1,
          date: sortedDays[index].date,
          spots: [
            for (final place in sortedDays[index].validCommitPlaces)
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
