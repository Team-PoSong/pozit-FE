class TouristSpotSearchResultModel {
  final String contentId;
  final String contentTypeId;
  final String title;
  final String address;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const TouristSpotSearchResultModel({
    required this.contentId,
    required this.contentTypeId,
    required this.title,
    required this.address,
    this.imageUrl = '',
    required this.latitude,
    required this.longitude,
  });

  factory TouristSpotSearchResultModel.fromJson(Map<String, dynamic> json) {
    return TouristSpotSearchResultModel(
      contentId: json['contentid'] as String,
      contentTypeId: json['contenttypeid'] as String,
      title: json['title'] as String,
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class TouristSpotSearchPage {
  final List<TouristSpotSearchResultModel> places;
  final int currentCursor;
  final int? nextCursor;
  final bool hasNext;

  const TouristSpotSearchPage({
    required this.places,
    required this.currentCursor,
    required this.nextCursor,
    required this.hasNext,
  });

  factory TouristSpotSearchPage.fromJson(Map<String, dynamic> json) {
    return TouristSpotSearchPage(
      places:
          (json['places'] as List<dynamic>?)
              ?.map(
                (e) => TouristSpotSearchResultModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      currentCursor: json['currentCursor'] as int,
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool,
    );
  }
}
