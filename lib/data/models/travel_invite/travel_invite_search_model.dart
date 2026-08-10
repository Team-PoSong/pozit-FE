import '../../../core/design_system/app_travel_status.dart';

enum TravelInviteSearchStatus { joinable, alreadyJoined, unavailable }

TravelInviteSearchStatus _parseInviteStatus(String raw) {
  return switch (raw) {
    'JOINABLE' => TravelInviteSearchStatus.joinable,
    'ALREADY_JOINED' => TravelInviteSearchStatus.alreadyJoined,
    'UNAVAILABLE' => TravelInviteSearchStatus.unavailable,
    _ => throw FormatException('알 수 없는 초대 코드 조회 상태입니다: $raw'),
  };
}

AppTravelStatus _parseTravelStatus(String raw) {
  return switch (raw) {
    'BEFORE' => AppTravelStatus.upcoming,
    'IN_PROGRESS' => AppTravelStatus.inProgress,
    'DONE' => AppTravelStatus.completed,
    _ => throw FormatException('알 수 없는 여행 상태입니다: $raw'),
  };
}

String _sanitizeBackgroundImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final uri = Uri.tryParse(raw);
  if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
    return '';
  }
  return raw;
}

class TravelInviteSearchModel {
  static const int inviteCodeLength = 5;

  const TravelInviteSearchModel({
    required this.status,
    required this.travelStatus,
    required this.message,
    required this.travelId,
    required this.title,
    required this.destination,
    required this.leader,
    required this.memberCount,
    required this.tags,
    required this.startDate,
    required this.endDate,
    required this.backgroundImageUrl,
  });

  factory TravelInviteSearchModel.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['startDate'] as String);
    final endDate = DateTime.parse(json['endDate'] as String);
    if (endDate.isBefore(startDate)) {
      throw const FormatException('여행 종료일은 시작일보다 빠를 수 없습니다.');
    }

    return TravelInviteSearchModel(
      status: _parseInviteStatus(json['inviteStatus'] as String),
      travelStatus: _parseTravelStatus(json['travelStatus'] as String),
      message: json['message'] as String,
      travelId: json['travelId'] as int,
      title: json['title'] as String,
      destination: json['destination'] as String,
      leader: json['leader'] as String,
      memberCount: json['memberCount'] as int,
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      startDate: startDate,
      endDate: endDate,
      backgroundImageUrl: _sanitizeBackgroundImageUrl(
        json['backgroundImageUrl'] as String?,
      ),
    );
  }

  final TravelInviteSearchStatus status;
  final AppTravelStatus travelStatus;
  final String message;
  final int travelId;
  final String title;
  final String destination;
  final String leader;
  final int memberCount;
  final List<String> tags;
  final DateTime startDate;
  final DateTime endDate;
  final String backgroundImageUrl;
}
