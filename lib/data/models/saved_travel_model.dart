import 'package:flutter/widgets.dart';

import '../../core/design_system/app_travel_status.dart';
import 'travel_course_model.dart';
import 'travel_info_card_model.dart';

/// 홈에 표시할 저장된 여행 정보입니다.
class SavedTravelModel {
  const SavedTravelModel({
    required this.id,
    required this.title,
    required this.location,
    required this.dateText,
    required this.author,
    required this.info,
    required this.courses,
    this.status = AppTravelStatus.upcoming,
    this.dDay,
    this.backgroundImage,
    this.tags = const [],
    this.participantCount,
  });

  final String id;
  final String title;
  final String location;
  final String dateText;
  final String author;
  final TravelInfoCardModel info;
  final List<TravelCourseModel> courses;
  final AppTravelStatus status;
  final String? dDay;
  final ImageProvider<Object>? backgroundImage;
  final List<String> tags;
  final int? participantCount;
}
