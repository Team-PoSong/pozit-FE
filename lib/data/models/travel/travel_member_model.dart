import 'package:flutter/foundation.dart';

const Set<String> _kLeaderRoleSynonyms = {'leader', 'owner', 'host', 'admin'};

bool _isLeaderRole(String raw) {
  final normalized = raw.toLowerCase().replaceAll('_', '');
  final isLeader = _kLeaderRoleSynonyms.contains(normalized);
  if (!isLeader && normalized != 'member' && normalized != 'guest') {
    debugPrint('알 수 없는 멤버 role: $raw');
  }
  return isLeader;
}

class TravelMemberModel {
  final int userId;
  final String nickname;
  final bool isLeader;

  const TravelMemberModel({
    required this.userId,
    required this.nickname,
    required this.isLeader,
  });

  factory TravelMemberModel.fromJson(Map<String, dynamic> json) {
    return TravelMemberModel(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      isLeader: _isLeaderRole(json['role'] as String),
    );
  }
}
