// 여행 코스(일차별 방문 장소) 관련 API 응답 모델을 정의합니다.

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

/// 하루치 코스입니다. [spots]는 서버가 준 순서를 신뢰하지 않고 [CourseSpotModel.orderIndex]
/// 기준으로 정렬해 사용합니다.
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

  /// 해당 일차에 가장 먼저 방문하는 여행지 이름입니다. 정보가 없으면 빈 문자열입니다.
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
