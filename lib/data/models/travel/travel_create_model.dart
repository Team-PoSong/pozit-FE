class TravelCreateRequest {
  const TravelCreateRequest({
    required this.title,
    required this.destination,
    required this.regionCode,
    required this.startDate,
    required this.endDate,
    required this.tagIds,
    this.transportation,
    this.travelStyle,
  });

  final String title;
  final String destination;
  final String regionCode;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> tagIds;
  final String? transportation;
  final String? travelStyle;

  Map<String, dynamic> toJson() => {
    'title': title,
    'destination': destination,
    'regionCode': regionCode,
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
    if (transportation != null) 'transportation': transportation,
    if (travelStyle != null) 'travelStyle': travelStyle,
    'tagIds': tagIds,
  };

  static String formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class CreatedCourseModel {
  const CreatedCourseModel({
    required this.courseId,
    required this.dayNumber,
    required this.date,
  });

  final int courseId;
  final int dayNumber;
  final DateTime date;

  factory CreatedCourseModel.fromJson(Map<String, dynamic> json) {
    return CreatedCourseModel(
      courseId: json['courseId'] as int,
      dayNumber: json['dayNumber'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class TravelCreateResult {
  const TravelCreateResult({required this.travelId, required this.courses});

  final int travelId;
  final List<CreatedCourseModel> courses;

  factory TravelCreateResult.fromJson(Map<String, dynamic> json) {
    return TravelCreateResult(
      travelId: json['travelId'] as int,
      courses: (json['courses'] as List<dynamic>? ?? const [])
          .map(
            (item) => CreatedCourseModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
