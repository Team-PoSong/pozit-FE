/// 관광공사 API 검색 결과 한 건입니다. 아직 Pozit DB에 저장되지 않았으므로
/// touristSpotId가 없고, 대신 관광공사의 contentId로 식별합니다.
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
