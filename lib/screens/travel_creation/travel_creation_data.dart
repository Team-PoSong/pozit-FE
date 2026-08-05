import 'package:flutter/material.dart';

class TravelInfoResult {
  const TravelInfoResult({
    required this.destination,
    required this.dateRange,
    required this.name,
    required this.tags,
  });

  final String destination;
  final DateTimeRange dateRange;
  final String name;
  final Set<String> tags;
}
