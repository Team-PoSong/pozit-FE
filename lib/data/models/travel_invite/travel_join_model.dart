class TravelJoinModel {
  const TravelJoinModel({required this.travelId, required this.travelMemberId});

  factory TravelJoinModel.fromJson(Map<String, dynamic> json) {
    return TravelJoinModel(
      travelId: json['travelId'] as int,
      travelMemberId: json['travelMemberId'] as int,
    );
  }

  final int travelId;
  final int travelMemberId;
}
