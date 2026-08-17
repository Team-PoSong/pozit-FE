import '../../../core/design_system/app_travel_status.dart';
import 'travel_course_model.dart';
import 'travel_member_model.dart';

class PublicTravelDetailModel {
  const PublicTravelDetailModel({
    required this.travelId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isPublic,
    required this.backgroundImageUrl,
    required this.leaderNickname,
    required this.memberCount,
    required this.completionRate,
    required this.totalSpotCount,
    required this.totalPozingCount,
    required this.tags,
    required this.likeCount,
    required this.isLiked,
    required this.courses,
    required this.members,
  });

  final int travelId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final AppTravelStatus status;
  final bool isPublic;
  final String backgroundImageUrl;
  final String leaderNickname;
  final int memberCount;
  final int completionRate;
  final int totalSpotCount;
  final int totalPozingCount;
  final List<String> tags;
  final int likeCount;
  final bool isLiked;
  final List<TravelCourseModel> courses;
  final List<TravelMemberModel> members;

  factory PublicTravelDetailModel.fromJson(Map<String, dynamic> json) {
    final leaderNickname = json['leaderNickname'] as String? ?? '';
    final rawCourses = (json['courses'] as List<dynamic>? ?? const [])
        .map((item) => TravelCourseModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final rawMembers = json['members'] as List<dynamic>? ?? const [];
    final displayIdsByNickname = <String, int>{};
    final members = <TravelMemberModel>[];
    for (final item in rawMembers) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('공개 여행 멤버 응답 형식이 올바르지 않습니다.');
      }
      final nickname = item['nickname'] as String;
      final role = item['role'] as String;
      if (displayIdsByNickname.containsKey(nickname)) {
        throw const FormatException('공개 여행 멤버 닉네임이 중복되었습니다.');
      }
      final displayId = -(displayIdsByNickname.length + 1);
      displayIdsByNickname[nickname] = displayId;
      members.add(
        TravelMemberModel(
          userId: displayId,
          nickname: nickname,
          isLeader: role == 'LEADER',
        ),
      );
    }

    return PublicTravelDetailModel(
      travelId: json['travelId'] as int,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _parseStatus(json['status'] as String),
      isPublic: json['isPublic'] as bool,
      backgroundImageUrl: json['backgroundImageUrl'] as String? ?? '',
      leaderNickname: leaderNickname,
      memberCount: json['memberCount'] as int,
      completionRate: json['completionRate'] as int,
      totalSpotCount: json['totalSpotCount'] as int,
      totalPozingCount: json['totalPozingCount'] as int,
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      likeCount: json['likeCount'] as int,
      isLiked: json['isLiked'] as bool,
      courses: _withPublicDisplayIds(rawCourses, displayIdsByNickname),
      members: members,
    );
  }
}

List<TravelCourseModel> _withPublicDisplayIds(
  List<TravelCourseModel> courses,
  Map<String, int> displayIdsByNickname,
) {
  return courses
      .map(
        (course) => TravelCourseModel(
          courseId: course.courseId,
          dayNumber: course.dayNumber,
          date: course.date,
          initialFocusSpotId: course.initialFocusSpotId,
          spots: course.spots
              .map(
                (spot) => spot.copyWith(
                  pozings: spot.pozings
                      .map(
                        (pozing) => PozingModel(
                          pozingId: pozing.pozingId,
                          userId: displayIdsByNickname[pozing.nickname],
                          nickname: pozing.nickname,
                          pozingUrl: pozing.pozingUrl,
                          thumbnailUrl: pozing.thumbnailUrl,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

AppTravelStatus _parseStatus(String status) {
  if (status != 'DONE') {
    throw FormatException('공개할 수 없는 여행 상태입니다: $status');
  }
  return AppTravelStatus.completed;
}
