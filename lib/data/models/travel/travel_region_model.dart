class TravelRegionModel {
  const TravelRegionModel({required this.code, required this.name});

  final String code;
  final String name;

  factory TravelRegionModel.fromJson(Map<String, dynamic> json) {
    return TravelRegionModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}

class TravelRegionPage {
  const TravelRegionPage({
    required this.regions,
    required this.currentCursor,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<TravelRegionModel> regions;
  final int currentCursor;
  final int? nextCursor;
  final bool hasNext;

  factory TravelRegionPage.fromJson(Map<String, dynamic> json) {
    return TravelRegionPage(
      regions: (json['regions'] as List<dynamic>? ?? const [])
          .map(
            (item) => TravelRegionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      currentCursor: json['currentCursor'] as int? ?? 1,
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
