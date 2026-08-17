class ActiveCourseSpotModel {
  final int travelId;
  final int courseSpotId;
  final int touristSpotId;
  final String name;
  final double latitude;
  final double longitude;

  const ActiveCourseSpotModel({
    required this.travelId,
    required this.courseSpotId,
    required this.touristSpotId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory ActiveCourseSpotModel.fromJson(Map<String, dynamic> json) {
    return ActiveCourseSpotModel(
      travelId: json['travelId'] as int,
      courseSpotId: json['courseSpotId'] as int,
      touristSpotId: json['touristSpotId'] as int,
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
