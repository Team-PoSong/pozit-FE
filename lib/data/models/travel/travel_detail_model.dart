import 'package:flutter/foundation.dart';

import '../../../core/design_system/app_travel_status.dart';
import 'travel_course_model.dart';
import 'travel_member_model.dart';

const Set<String> _kUpcomingStatusSynonyms = {'upcoming', 'before', 'ready'};
const Set<String> _kInProgressStatusSynonyms = {
  'inprogress',
  'ongoing',
  'traveling',
  'ing',
};
const Set<String> _kCompletedStatusSynonyms = {
  'completed',
  'done',
  'finished',
  'end',
};

String _sanitizeBackgroundImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';

  final uri = Uri.tryParse(raw);
  final isAbsoluteHttpUrl =
      uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  if (!isAbsoluteHttpUrl) {
    debugPrint('배경 사진 URL이 http(s) 절대 URL이 아니어서 무시합니다: $raw');
    return '';
  }
  return raw;
}

AppTravelStatus _parseTravelStatus(String raw) {
  final normalized = raw.toLowerCase().replaceAll('_', '');
  if (_kInProgressStatusSynonyms.contains(normalized)) {
    return AppTravelStatus.inProgress;
  }
  if (_kCompletedStatusSynonyms.contains(normalized)) {
    return AppTravelStatus.completed;
  }
  if (!_kUpcomingStatusSynonyms.contains(normalized)) {
    debugPrint('알 수 없는 여행 status: $raw');
  }
  return AppTravelStatus.upcoming;
}

class TravelDetailModel {
  final int travelId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final AppTravelStatus status;
  final bool isPublic;
  final String backgroundImageUrl;
  final String inviteCode;
  final int completionRate;
  final int totalSpotCount;
  final int totalPozingCount;
  final List<String> tags;
  final List<TravelMemberModel> members;
  final List<TravelCourseModel> courses;

  const TravelDetailModel({
    required this.travelId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isPublic,
    required this.backgroundImageUrl,
    required this.inviteCode,
    required this.completionRate,
    required this.totalSpotCount,
    required this.totalPozingCount,
    this.tags = const [],
    this.members = const [],
    this.courses = const [],
  });

  factory TravelDetailModel.fromJson(Map<String, dynamic> json) {
    return TravelDetailModel(
      travelId: json['travelId'] as int,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _parseTravelStatus(json['status'] as String),
      isPublic: json['isPublic'] as bool,
      backgroundImageUrl: _sanitizeBackgroundImageUrl(
        json['backgroundImageUrl'] as String?,
      ),
      inviteCode: json['inviteCode'] as String? ?? '',
      completionRate: json['completionRate'] as int,
      totalSpotCount: json['totalSpotCount'] as int,
      totalPozingCount: json['totalPozingCount'] as int,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => TravelMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      courses:
          (json['courses'] as List<dynamic>?)
              ?.map((e) => TravelCourseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
