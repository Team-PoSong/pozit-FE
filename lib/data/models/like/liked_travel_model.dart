import '../../../core/design_system/app_travel_status.dart';

class LikedTravelModel {
  const LikedTravelModel({
    required this.travelId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isPublic,
    required this.backgroundImageUrl,
    required this.completionRate,
    required this.tags,
    required this.leaderNickname,
    required this.memberCount,
    required this.likeCount,
    required this.isLiked,
  });

  final int travelId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final AppTravelStatus status;
  final bool isPublic;
  final String backgroundImageUrl;
  final int completionRate;
  final List<String> tags;
  final String leaderNickname;
  final int memberCount;
  final int likeCount;
  final bool isLiked;

  factory LikedTravelModel.fromJson(Map<String, dynamic> json) {
    return LikedTravelModel(
      travelId: json['travelId'] as int,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _parseStatus(json['status'] as String),
      isPublic: json['isPublic'] as bool,
      backgroundImageUrl: json['backgroundImageUrl'] as String? ?? '',
      completionRate: json['completionRate'] as int,
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      leaderNickname: json['leaderNickname'] as String? ?? '',
      memberCount: json['memberCount'] as int,
      likeCount: json['likeCount'] as int,
      isLiked: json['isLiked'] as bool,
    );
  }
}

AppTravelStatus _parseStatus(String status) {
  return switch (status.toUpperCase()) {
    'DONE' || 'COMPLETED' || 'FINISHED' => AppTravelStatus.completed,
    'IN_PROGRESS' ||
    'INPROGRESS' ||
    'ONGOING' ||
    'TRAVELING' => AppTravelStatus.inProgress,
    _ => AppTravelStatus.upcoming,
  };
}
