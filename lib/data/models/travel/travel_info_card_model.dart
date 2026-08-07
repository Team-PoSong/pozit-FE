import 'travel_course_model.dart';
import 'travel_detail_model.dart';

class TravelInfoCardModel {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int companionCount;
  final List<String> tags;
  final int visitedPlaceCount;
  final int recordCount;
  final double completionRate;

  TravelInfoCardModel({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.companionCount,
    this.tags = const [],
    required this.visitedPlaceCount,
    required this.recordCount,
    required this.completionRate,
  }) {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('endDate는 startDate보다 빠를 수 없습니다.');
    }
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;

  int get nights => totalDays - 1;

  String get durationText => nights <= 0 ? '당일치기' : '$nights박$totalDays일';

  String get dateRangeText =>
      '${startDate.month}/${startDate.day}-${endDate.month}/${endDate.day}';

  factory TravelInfoCardModel.fromTravelDetail(
    TravelDetailModel detail, {
    List<String>? tags,
  }) {
    return TravelInfoCardModel(
      destination: detail.destination,
      startDate: detail.startDate,
      endDate: detail.endDate,
      companionCount: detail.members.length,
      tags: tags ?? detail.tags,
      visitedPlaceCount: _countVisitedSpots(detail.courses),
      recordCount: detail.totalPozingCount,
      completionRate: detail.completionRate / 100.0,
    );
  }

  static int _countVisitedSpots(List<TravelCourseModel> courses) {
    final dayNumbers = courses.map((c) => c.dayNumber).toSet();
    var count = 0;
    for (final dayNumber in dayNumbers) {
      count += mergeSpotsForDay(
        courses,
        dayNumber,
      ).where((spot) => spot.status == 'visited').length;
    }
    return count;
  }

  factory TravelInfoCardModel.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['startDate'] as String);
    final endDate = DateTime.parse(json['endDate'] as String);
    if (endDate.isBefore(startDate)) {
      throw FormatException(
        'endDate($endDate)가 startDate($startDate)보다 빠를 수 없습니다.',
      );
    }

    return TravelInfoCardModel(
      destination: json['destination'] as String,
      startDate: startDate,
      endDate: endDate,
      companionCount: json['companionCount'] as int,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      visitedPlaceCount: json['visitedPlaceCount'] as int,
      recordCount: json['recordCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }
}
