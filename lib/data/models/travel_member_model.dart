class TravelMemberModel {
  final String nickname;
  final bool isLeader;

  const TravelMemberModel({required this.nickname, required this.isLeader});

  factory TravelMemberModel.fromJson(Map<String, dynamic> json) {
    return TravelMemberModel(
      nickname: json['nickname'] as String,
      isLeader: json['isLeader'] as bool,
    );
  }
}
