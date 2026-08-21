import 'user_profile_model.dart';

class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.pushEnabled,
    required this.travelEnabled,
    required this.groupEnabled,
    required this.pozingEnabled,
    required this.courseEnabled,
    required this.noticeEnabled,
  });

  final bool pushEnabled;
  final bool travelEnabled;
  final bool groupEnabled;
  final bool pozingEnabled;
  final bool courseEnabled;
  final bool noticeEnabled;

  NotificationSettingsModel copyWith({
    bool? pushEnabled,
    bool? travelEnabled,
    bool? groupEnabled,
    bool? pozingEnabled,
    bool? courseEnabled,
    bool? noticeEnabled,
  }) {
    return NotificationSettingsModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      travelEnabled: travelEnabled ?? this.travelEnabled,
      groupEnabled: groupEnabled ?? this.groupEnabled,
      pozingEnabled: pozingEnabled ?? this.pozingEnabled,
      courseEnabled: courseEnabled ?? this.courseEnabled,
      noticeEnabled: noticeEnabled ?? this.noticeEnabled,
    );
  }

  factory NotificationSettingsModel.fromProfile(UserProfileModel profile) {
    return NotificationSettingsModel(
      pushEnabled: profile.pushEnabled,
      travelEnabled: profile.notiTravelEnabled,
      groupEnabled: profile.notiGroupEnabled,
      pozingEnabled: profile.notiPozingEnabled,
      courseEnabled: profile.notiCourseEnabled,
      noticeEnabled: profile.notiNoticeEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'notiTravelEnabled': travelEnabled,
      'notiGroupEnabled': groupEnabled,
      'notiPozingEnabled': pozingEnabled,
      'notiCourseEnabled': courseEnabled,
      'notiNoticeEnabled': noticeEnabled,
    };
  }
}
