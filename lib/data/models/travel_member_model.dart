// 여행 멤버 목록에 표시되는 데이터를 정의합니다.

class TravelMemberModel {
  final String nickname;
  final String userId;
  final bool isLeader;

  const TravelMemberModel({
    required this.nickname,
    required this.userId,
    required this.isLeader,
  });

  factory TravelMemberModel.fromJson(Map<String, dynamic> json) {
    return TravelMemberModel(
      nickname: json['nickname'] as String,
      userId: json['userId'] as String,
      isLeader: json['isLeader'] as bool,
    );
  }
}
