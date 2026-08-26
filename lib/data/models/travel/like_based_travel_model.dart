import 'travel_create_model.dart';

class LikeBasedTravelDraftModel {
  const LikeBasedTravelDraftModel({
    required this.sourceTravelId,
    required this.title,
    required this.destination,
    required this.regionCode,
    required this.tagIds,
    this.transportation,
    this.travelStyle,
    this.backgroundImageUrl,
  });

  final int sourceTravelId;
  final String title;
  final String destination;
  final String regionCode;
  final List<int> tagIds;
  final String? transportation;
  final String? travelStyle;
  final String? backgroundImageUrl;

  factory LikeBasedTravelDraftModel.fromJson(Map<String, dynamic> json) {
    return LikeBasedTravelDraftModel(
      sourceTravelId: json['sourceTravelId'] as int,
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      regionCode: json['regionCode'] as String? ?? '',
      tagIds: (json['tagIds'] as List<dynamic>? ?? const []).cast<int>(),
      transportation: json['transportation'] as String?,
      travelStyle: json['travelStyle'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
    );
  }
}

class LikeBasedTravelCreateRequest {
  const LikeBasedTravelCreateRequest({
    required this.sourceTravelId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.tagIds,
    required this.courses,
    this.transportation,
    this.travelStyle,
    this.backgroundImageUrl,
  });

  final int sourceTravelId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> tagIds;
  final List<LikeBasedCourseRequest> courses;
  final String? transportation;
  final String? travelStyle;
  final String? backgroundImageUrl;

  Map<String, dynamic> toJson() => {
    'sourceTravelId': sourceTravelId,
    'title': title,
    'startDate': TravelCreateRequest.formatDate(startDate),
    'endDate': TravelCreateRequest.formatDate(endDate),
    if (transportation != null) 'transportation': transportation,
    if (travelStyle != null) 'travelStyle': travelStyle,
    if (backgroundImageUrl != null) 'backgroundImageUrl': backgroundImageUrl,
    'tagIds': tagIds,
    'courses': courses.map((course) => course.toJson()).toList(),
  };
}

class LikeBasedCourseRequest {
  const LikeBasedCourseRequest({
    required this.dayNumber,
    required this.touristSpotIds,
  });

  final int dayNumber;
  final List<int> touristSpotIds;

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'touristSpotIds': touristSpotIds,
  };
}
