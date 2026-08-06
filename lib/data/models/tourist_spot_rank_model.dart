class TouristSpotRankModel {
  final int rank;
  final int touristSpotId;
  final String title;
  final String address;
  final String imageUrl;
  final int courseSpotCount;

  const TouristSpotRankModel({
    required this.rank,
    required this.touristSpotId,
    required this.title,
    required this.address,
    this.imageUrl = '',
    required this.courseSpotCount,
  });

  factory TouristSpotRankModel.fromJson(Map<String, dynamic> json) {
    return TouristSpotRankModel(
      rank: json['rank'] as int,
      touristSpotId: json['touristSpotId'] as int,
      title: json['title'] as String,
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      courseSpotCount: json['courseSpotCount'] as int,
    );
  }
}

class TouristSpotRankPage {
  final List<TouristSpotRankModel> ranks;
  final int currentCursor;
  final int? nextCursor;
  final bool hasNext;

  const TouristSpotRankPage({
    required this.ranks,
    required this.currentCursor,
    required this.nextCursor,
    required this.hasNext,
  });

  factory TouristSpotRankPage.fromJson(Map<String, dynamic> json) {
    return TouristSpotRankPage(
      ranks:
          (json['ranks'] as List<dynamic>?)
              ?.map(
                (e) => TouristSpotRankModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      currentCursor: json['currentCursor'] as int,
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool,
    );
  }
}
