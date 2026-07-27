class PozingModel {
  final int pozingId;
  final int userId;
  final String nickname;
  final String pozingUrl;
  final String thumbnailUrl;

  const PozingModel({
    required this.pozingId,
    required this.userId,
    required this.nickname,
    required this.pozingUrl,
    required this.thumbnailUrl,
  });

  factory PozingModel.fromJson(Map<String, dynamic> json) {
    return PozingModel(
      pozingId: json['pozingId'] as int,
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      pozingUrl: json['pozingUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

class CourseSpotModel {
  final int courseSpotId;
  final int touristSpotId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int orderIndex;
  final String status;
  final List<PozingModel> pozings;

  const CourseSpotModel({
    required this.courseSpotId,
    required this.touristSpotId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.orderIndex,
    required this.status,
    this.pozings = const [],
  });

  factory CourseSpotModel.fromJson(Map<String, dynamic> json) {
    return CourseSpotModel(
      courseSpotId: json['courseSpotId'] as int,
      touristSpotId: json['touristSpotId'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      orderIndex: json['orderIndex'] as int,
      status: json['status'] as String,
      pozings:
          (json['pozings'] as List<dynamic>?)
              ?.map((e) => PozingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class TravelCourseModel {
  final int courseId;
  final int dayNumber;
  final DateTime date;
  final List<CourseSpotModel> spots;

  const TravelCourseModel({
    required this.courseId,
    required this.dayNumber,
    required this.date,
    this.spots = const [],
  });

  String get firstSpotName {
    if (spots.isEmpty) return '';
    final sorted = [...spots]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted.first.name;
  }

  factory TravelCourseModel.fromJson(Map<String, dynamic> json) {
    return TravelCourseModel(
      courseId: json['courseId'] as int,
      dayNumber: json['dayNumber'] as int,
      date: DateTime.parse(json['date'] as String),
      spots:
          (json['spots'] as List<dynamic>?)
              ?.map((e) => CourseSpotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
