import 'package:flutter/material.dart';

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
  });

  final String destination;
  final DateTimeRange dateRange;
  final String name;
  final Set<String> tags;
  final TravelCreationMethod creationMethod;
  final String? transportation;
  final int? densityLevel;

  TravelInfoResult copyWith({String? transportation, int? densityLevel}) {
    return TravelInfoResult(
      destination: destination,
      dateRange: dateRange,
      name: name,
      tags: tags,
      creationMethod: creationMethod,
      transportation: transportation ?? this.transportation,
      densityLevel: densityLevel ?? this.densityLevel,
    );
  }
}
