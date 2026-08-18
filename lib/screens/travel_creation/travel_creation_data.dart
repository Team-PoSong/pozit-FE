import 'package:flutter/material.dart';

import '../../data/models/travel/travel_course_model.dart';

enum TravelCreationMethod { recommendation, create, wish }

class TravelInfoResult {
  const TravelInfoResult({
    required this.destination,
    required this.dateRange,
    required this.name,
    required this.tags,
    this.creationMethod = TravelCreationMethod.create,
    this.transportation,
    this.densityLevel,
    this.initialCourses = const [],
  });

  final String destination;
  final DateTimeRange dateRange;
  final String name;
  final Set<String> tags;
  final TravelCreationMethod creationMethod;
  final String? transportation;
  final int? densityLevel;
  final List<TravelCourseModel> initialCourses;

  TravelInfoResult copyWith({String? transportation, int? densityLevel}) {
    return TravelInfoResult(
      destination: destination,
      dateRange: dateRange,
      name: name,
      tags: tags,
      creationMethod: creationMethod,
      transportation: transportation ?? this.transportation,
      densityLevel: densityLevel ?? this.densityLevel,
      initialCourses: initialCourses,
    );
  }
}
