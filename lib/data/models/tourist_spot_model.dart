class TouristSpotModel {
  final int touristSpotId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const TouristSpotModel({
    required this.touristSpotId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory TouristSpotModel.fromJson(Map<String, dynamic> json) {
    return TouristSpotModel(
      touristSpotId: json['touristSpotId'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
