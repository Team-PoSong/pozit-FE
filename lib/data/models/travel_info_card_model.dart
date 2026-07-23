// 여행 정보 카드에 표시되는 데이터를 정의합니다.

class TravelInfoCardModel {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int companionCount;
  final List<String> tags;
  final int visitedPlaceCount;
  final int recordCount;
  final double completionRate;

  const TravelInfoCardModel({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.companionCount,
    this.tags = const [],
    required this.visitedPlaceCount,
    required this.recordCount,
    required this.completionRate,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  int get nights => totalDays - 1;

  String get durationText => nights <= 0 ? '당일치기' : '$nights박 $totalDays일';

  String get dateRangeText =>
      '${startDate.month}.${startDate.day} - ${endDate.month}.${endDate.day}';

  factory TravelInfoCardModel.fromJson(Map<String, dynamic> json) {
    return TravelInfoCardModel(
      destination:      json['destination']      as String,
      startDate:         DateTime.parse(json['startDate'] as String),
      endDate:           DateTime.parse(json['endDate'] as String),
      companionCount:    json['companionCount']    as int,
      tags:              (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      visitedPlaceCount: json['visitedPlaceCount'] as int,
      recordCount:       json['recordCount']       as int,
      completionRate:    (json['completionRate'] as num).toDouble(),
    );
  }
}
