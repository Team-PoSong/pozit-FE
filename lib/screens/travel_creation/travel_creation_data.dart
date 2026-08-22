import 'package:flutter/material.dart';

import '../../data/models/travel/travel_course_model.dart';

enum TravelCreationMethod { recommendation, create, wish }

class TravelCreationDraft {
  const TravelCreationDraft({
    required this.destination,
    this.regionCode,
    required this.dateRange,
    required this.name,
    required this.tags,
    this.tagIds = const [],
    this.creationMethod = TravelCreationMethod.create,
    this.transportation,
    this.densityLevel,
    this.initialCourses = const [],
    this.sourceTravelId,
    this.backgroundImageUrl,
  });

  final String destination;
  final String? regionCode;
  final DateTimeRange dateRange;
  final String name;
  final Set<String> tags;
  final List<int> tagIds;
  final TravelCreationMethod creationMethod;
  final String? transportation;
  final int? densityLevel;
  final List<TravelCourseModel> initialCourses;
  final int? sourceTravelId;
  final String? backgroundImageUrl;

  TravelCreationDraft copyWith({String? transportation, int? densityLevel}) {
    return TravelCreationDraft(
      destination: destination,
      regionCode: regionCode,
      dateRange: dateRange,
      name: name,
      tags: tags,
      tagIds: tagIds,
      creationMethod: creationMethod,
      transportation: transportation ?? this.transportation,
      densityLevel: densityLevel ?? this.densityLevel,
      initialCourses: initialCourses,
      sourceTravelId: sourceTravelId,
      backgroundImageUrl: backgroundImageUrl,
    );
  }
}

typedef TravelInfoResult = TravelCreationDraft;
